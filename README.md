# niriwm-nix

NixOS flake with two hosts:

| Host | Desktop | Home Manager | sing-box |
|---|---|---|---|
| `W550` | niri + Dux Shell | yes | yes |
| `BT-7274` | KDE Plasma 6 + SDDM | yes | yes |

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
  sing-box.yaml         
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

编辑 secret：

```bash
sudo SOPS_AGE_KEY_FILE=/var/lib/sops-nix/age.key EDITOR=nvim sops secrets/sing-box.yaml
```

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

## 更新依赖

```bash
nix flake update
```

更新后建议先 `nix flake check path:.`，确认无误再 `nixos-rebuild switch`。
