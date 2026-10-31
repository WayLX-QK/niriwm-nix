# niriwm-nix

NixOS flake with two hosts:

| Host | Desktop | Home Manager | sing-box |
|---|---|---|---|
| `W550` | niri + Dux Shell | yes | yes |
| `BT-7274` | KDE Plasma 6 + SDDM | yes | yes |

两台主机当前共用同一套 sing-box 配置、同一份加密 secret 和同一套字体配置。

## 目录结构

```text
hosts/
  W550/                 settings + home.nix + home-packages.nix + private hardware config
  BT-7274/              settings + home.nix + home-packages.nix + private hardware config
modules/
  system/               共享基线：boot/locale/networking/nix/sound/fonts/openssh/printing/flatpak/users
                        input-method（系统级 fcitx5）
  services/             greetd、upower、power-profiles-daemon、sing-box
  security/             polkit、gnome-keyring
  desktop/              niri-profile、niri、Dux Shell、Thunar、portal、dconf、plasma
  hardware/             intel-gpu、vfio、qmk、vulkan
  virtualisation/       docker、libvirtd、podman
  home/                 common、niri-profile、gtk、niri、foot、wallpapers
                        input-method/fcitx5-rime（共享 Rime 用户配置）
secrets/
  sing-box.yaml         sops 加密后的 secret（可提交）
```

## fcitx5-rime

引擎和基础数据在系统级：

- `modules/system/input-method.nix`
- `fcitx5` + `fcitx5-rime` + `fcitx5-fluent`
- `rime-ice` 基础方案
- `systemd.user.services.fcitx5-daemon`

用户级配置由两台主机共享：

- `modules/home/input-method/fcitx5-rime/`
- `fcitx5/profile`
- `rime/default.custom.yaml`
- 以后可继续加入 `rime_ice.custom.yaml`、自定义词库、`fcitx5/themes` 等

注意：

- 不要用 `home.file` 递归管理整个 `~/.local/share/fcitx5/rime`；
- Rime 的 `*.userdb`、`user.yaml`、`installation.yaml`、`*.bin` 是运行时数据，不归 HM 管理；
- 皮肤如果指 fcitx5 主题，放 `xdg.dataFile."fcitx5/themes/..."`；
- Rime 的 Squirrel/Weasel 皮肤不适用于 Linux fcitx5。

## 私有配置

### hardware-configuration.nix（不提交）

每台主机的 `hosts/<host>/hardware-configuration.nix` 都包含磁盘 UUID、swap 等硬件指纹，
已被 `.gitignore` 忽略，**不要提交，也不要跨主机复制**。

在宿主机上生成或复制：

```bash
sudo nixos-generate-config --dir hosts/W550
# 或
cp /etc/nixos/hardware-configuration.nix hosts/W550/
```

### sing-box secret（加密入库）

`secrets/sing-box.yaml` 使用 sops-nix + age 加密，两台主机当前共用同一份文件。
加密文件使用嵌套结构，例如：

```yaml
sing-box:
  naive_server: ...
  naive_server_name: ...
  naive_username: ...
  naive_password: ...
```

Nix 侧通过 `key` 指向嵌套字段：

```nix
sops.secrets."sing-box-naive-server" = {
  key = "sing-box/naive_server";
  owner = "sing-box";
  mode = "0400";
};
```

解密后的文件位于 `/run/secrets/`，不会进入 Nix store。

两台主机共用同一个 age 私钥路径：

```text
/var/lib/sops-nix/age.key
```

需要把 BT-7274 上已有的 age 私钥安全复制到 W550，或者后续给 W550 生成独立 key
并把公钥加入 `.sops.yaml` 的 recipients。该私钥**绝不能提交**。

编辑 secret：

```bash
sudo SOPS_AGE_KEY_FILE=/var/lib/sops-nix/age.key EDITOR=nvim sops secrets/sing-box.yaml
```

## sing-box 模式

`modules/services/sing-box.nix` 当前启用：

- SOCKS `127.0.0.1:1080`
- HTTP `0.0.0.0:8080`（NixOS 防火墙默认未放行）
- naive outbound + DNS/route 规则

TUN 配置保留为注释，避免修改系统路由。启用 TUN 时需要同时取消注释
`CAP_NET_ADMIN` / `CAP_NET_RAW` 配置，并测试 `auto_route`/防火墙行为。

`nix-daemon` 的代理固定为 `http://127.0.0.1:8080`，与 `http-in` 端口一致。

## Home Manager

两台主机的用户包都在 `home.packages`：

- `hosts/W550/home-packages.nix`
- `hosts/BT-7274/home-packages.nix`

NixOS 侧 `users.users.<name>` 只管理身份和组。

字体也统一使用 `modules/system/fonts.nix`（采用 BT-7274 的字体方案）。

## build / check

Git flake 只会复制被 Git 跟踪的文件；`hardware-configuration.nix` 仍是本地文件，
因此本地构建/检查使用 `path:`：

```bash
# W550
sudo nixos-rebuild switch --flake path:.#W550

# BT-7274
sudo nixos-rebuild switch --flake path:.#BT-7274

# 检查所有主机（读取本地硬件文件）
nix flake check path:.
```

## stateVersion

`stateVersion` 是安装时的兼容性默认值标记，不是 NixOS 版本号：

- `hosts/<host>/settings.nix` 中的 `systemStateVersion` 控制 NixOS；
- `hosts/<host>/settings.nix` 中的 `homeStateVersion` 控制 Home Manager；
- 两者独立评估，不要因为升级系统就同时盲目修改。

## 更新依赖

```bash
# 不需要 sudo；在仓库根目录执行
nix flake update
```

更新后建议先 `nix flake check path:.`，确认无误再 `nixos-rebuild switch`。
