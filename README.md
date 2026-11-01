# niriwm-nix

NixOS flake，当前管理两台主机：

| 主机 | 桌面 | 建议的 profile 昵称 |
|---|---|---|
| `W550` | niri + Dux Shell | `niriwm` |
| `BT-7274` | KDE Plasma 6 + SDDM | `kde` |

设计取舍：

- **不设置全局代理**：只有 Nix 构建和显式命令走代理；
- **sing-box 不启用 TUN**：TUN + `auto_route` 会接管整台主机流量；
- **输入法只用 fcitx5-rime（rime-ice）**，不使用 IBus；
- **systemd-boot**，`configurationLimit = 3`。

## 快速开始

前提：

- 宿主机是 NixOS，已启用 flakes；
- `hosts/<host>/hardware-configuration.nix` 已生成并放在对应目录；
- `secrets/sing-box.yaml` 已用 sops 加密，`/var/lib/sops-nix/age.key` 可用。

`-p` 是命名 system profile 的昵称，**不是 flake 关键字**，名字任意：

```bash
# W550
PROFILE=niriwm
nrb switch -p "$PROFILE" --flake path:.#W550

# BT-7274
PROFILE=kde
nrb switch -p "$PROFILE" --flake path:.#BT-7274
```

`nrb` 是下面“构建代理”里的 shell 函数，只给这一次 `nixos-rebuild` 注入代理；
没有定义它时，改用：

```bash
sudo nixos-rebuild switch -p "$PROFILE" --flake path:.#BT-7274
```

首次切换后：

```bash
sudo systemctl restart nix-daemon
sudo systemctl restart sing-box
systemctl status sing-box
```

检查：

```bash
ss -lntp | grep -E '8080|1080'
curl -x http://127.0.0.1:8080 -I https://cache.nixos.org/nix-cache-info
curl -x http://127.0.0.1:8080 -I https://github.com
```

> 必须使用 `path:.`。`hardware-configuration.nix` 被 `.gitignore` 忽略，
> `git+file:` 不会包含它；`path:` 会包含工作区的未跟踪文件。

## Profile 与引导（`-p` 是什么）

`-p` / `--profile-name` 是 NixOS 的**命名 system profile**：

- 不写 `-p`：使用默认 `/nix/var/nix/profiles/system`；
- 写 `-p NAME`：使用 `/nix/var/nix/profiles/system-profiles/NAME`；
- `NAME` 只是昵称，`niriwm`、`kde`、`flakes` 都可以；
- 名字不会改变配置内容，只用于区分 profile/generation 和引导项；
- 换一个名字会创建一个新 profile，旧 profile 不会自动删除；
- 命名 profile 和默认 `system` 是两个独立的根，不建议同时混用。

查看当前 generation：

```bash
# 换成你实际使用的昵称
PROFILE=niriwm

readlink -f /nix/var/nix/profiles/system
readlink -f "/nix/var/nix/profiles/system-profiles/$PROFILE"

# 只在需要时使用；输出可能很长
sudo nix-env -p /nix/var/nix/profiles/system --list-generations
sudo nix-env -p "/nix/var/nix/profiles/system-profiles/$PROFILE" --list-generations
```

systemd-boot 条目由当前 generation 生成；`configurationLimit = 3` 限制保留条目数。
旧条目/旧 profile 的清理见“清理旧系统与引导”。

## 目录结构

```text
hosts/
  W550/                 settings + home.nix + home-packages.nix + private hardware config
  BT-7274/              settings + home.nix + home-packages.nix + private hardware config
modules/
  system/               共享基线：boot/locale/networking/nix/sound/fonts/openssh/printing/flatpak/users
  services/             greetd、upower、power-profiles-daemon、sing-box
  security/             polkit、gnome-keyring
  desktop/              niri-profile、niri、Dux Shell、Thunar、portal、dconf、plasma
  hardware/             intel-gpu、vfio、qmk、vulkan
  virtualisation/       docker、libvirtd、podman
  home/                 common、niri-profile、gtk、niri、foot、wallpapers
                        input-method/fcitx5-rime
secrets/
  sing-box.yaml         加密后的代理 secret
```

## 硬件与直通

### BT-7274

- 主板/CPU：B550M + Ryzen 5700X；
- 宿主机桌面显卡：**Intel Arc A380**，由 `xe` 驱动接管（device id `56a5`）；
- **RTX 3060** 直通给 Windows/Linux 虚拟机：
  - `10de:2503`（VGA）
  - `10de:228e`（HDMI Audio）
- 配置位置：
  - `hosts/BT-7274/settings.nix` 的 `vfioIds` 与 `intelGpu`；
  - `modules/hardware/vfio.nix` 的 IOMMU、`softdep`、QEMU 设置。

`vfio.nix` 中：

- `amd_iommu=on` / `iommu=pt` 针对 B550M + 5700X；
- `softdep nouveau/nvidia pre: vfio-pci` 让 vfio-pci 先绑定 RTX 3060；
- 本机没有 AMD GPU，所以不再配置 `softdep amdgpu`；
- `virtualisation.libvirtd.qemu.runAsRoot = true` 是为了 VFIO 直通兼容性，
  权限较大，请确保虚拟机来源可信；如果确认不需要，可以改成 `false` 后测试。

检查直通状态：

```bash
lspci -nnk | grep -A3 -E '10de:2503|10de:228e|8086:56a5'
sudo journalctl -k -b | grep -i -E 'iommu|vfio|xe'
```

### W550

- Tuxedo InfinityBook Pro 14 Gen9 AMD；
- niri + Dux Shell，建议 `-p niriwm`。

### 防火墙

BT-7274 的 80/443/UDP 4000–4007 目前**注释为模板**，默认不放行。
需要本地 Web、游戏或串流服务时，在 `hosts/BT-7274/settings.nix` 取消注释。

## 私有配置与 secrets

### hardware-configuration.nix（不提交）

每台主机的 `hosts/<host>/hardware-configuration.nix` 包含磁盘 UUID、swap 等硬件指纹，
已被 `.gitignore` 忽略，**不要提交，也不要跨主机复制**。

在宿主机上生成或复制：

```bash
sudo nixos-generate-config --dir hosts/W550
# 或
cp /etc/nixos/hardware-configuration.nix hosts/W550/
```

### sing-box secrets

编辑加密文件：

```bash
sudo SOPS_AGE_KEY_FILE=/var/lib/sops-nix/age.key \
  EDITOR=nvim sops secrets/sing-box.yaml
```

当前明文 secret 不会进入 Nix store：nixpkgs 的 `services.sing-box` 模块会在
`ExecStartPre` 中用 jq 展开 `_secret`，生成 `/run/sing-box/config.json`。

## 构建代理（只影响 Nix）

本配置**不设置全局代理**：没有 `networking.proxy`，也没有
`environment.sessionVariables`。代理只作用于：

- `nix-daemon` 的 substituters 下载；
- fixed-output derivation（`fetchurl`/`fetchgit`/`fetchzip` 等）的 `impure-env`；
- 你显式执行 `nixos-rebuild` / `nix flake update` 时注入的 client 环境。

> **TUN 是全局代理**：sing-box 的 `tun + auto_route` 会接管整台主机流量。
> 本项目只需要 Nix 构建走代理，因此 TUN 必须保持关闭；
> 不要为了让 `nixos-rebuild` 走代理而打开 TUN。终端和 Firefox 请按需设置。

`hosts/*/settings.nix` 的 `substituters` 保持**镜像优先、cache.nixos.org 兜底**：

- 镜像域名在 `modules/system/nix.nix` 的 `no_proxy` 中直连；
- 镜像没有的包再通过代理访问官方源；
- 端口以 `singBox.httpPort` 为准，默认 8080。

### `nrb`：只给当前命令注入代理

```bash
nrb() {
  sudo env \
    http_proxy=http://127.0.0.1:8080 \
    https_proxy=http://127.0.0.1:8080 \
    all_proxy=http://127.0.0.1:8080 \
    no_proxy=127.0.0.1,localhost,::1 \
    nixos-rebuild "$@"
}
```

用法：

```bash
nrb switch -p "$PROFILE" --flake path:.#BT-7274
nrb build -p "$PROFILE" --flake path:.#BT-7274
```

> `nrb` 只是当前 shell 的函数；重启后需要重新定义，或写进 `~/.bashrc`。
> 不想定义函数时，直接使用上面的 `sudo env ... nixos-rebuild` 形式。

首次切换后，让新的 daemon 环境生效：

```bash
sudo systemctl restart nix-daemon
sudo systemctl show nix-daemon -p Environment
```

### `nix flake update`

```bash
env http_proxy=http://127.0.0.1:8080 \
    https_proxy=http://127.0.0.1:8080 \
    all_proxy=http://127.0.0.1:8080 \
    no_proxy=127.0.0.1,localhost,::1 \
    nix flake update
```

更新后：

```bash
nix flake check path:.
```

如果检查需要拉取 input，再给检查命令加同样的代理环境。

### 终端工具和 Firefox

这些不属于 Nix 构建，按需在自己的 shell / 应用里设置，**不要写进系统环境**：

```bash
# 只对当前 shell 生效，不需要时 unset
export http_proxy=http://127.0.0.1:8080
export https_proxy=http://127.0.0.1:8080
export all_proxy=http://127.0.0.1:8080
export no_proxy=127.0.0.1,localhost,::1
```

Firefox 在“设置 → 网络设置 → 手动配置代理”中填写 HTTP/HTTPS 代理
`127.0.0.1:8080`，并勾选“也将此代理用于 HTTPS”。

> 普通构建（非 FOD）在 sandbox 中没有网络，这是 Nix 的设计；
> 如果某个包在 build 脚本里直接 `curl`/`git clone`，代理也救不了它，
> 应改成 `fetchurl`/`fetchgit` 等 FOD。

## 输入法

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

只使用 fcitx5-rime（rime-ice），不使用 IBus：

- NixOS 的 `i18n.inputMethod` 会设置 `XMODIFIERS` 和 `QT_PLUGIN_PATH`；
- 当前 `fcitx5.waylandFrontend = true`，所以**不会**设置
  `GTK_IM_MODULE` / `QT_IM_MODULE`；Wayland 原生应用走 text-input 协议；
- XWayland 应用通过 `XMODIFIERS` / XIM 使用 fcitx5；
- `SDL_IM_MODULE=fcitx` 由 Home Manager 设置；
- 如果某个 XWayland 的 GTK/Qt 应用无法输入中文，再针对该应用设置
  `GTK_IM_MODULE=fcitx` / `QT_IM_MODULE=fcitx`，不要全局强加；
- 不设置 `GLFW_IM_MODULE=ibus`：它只是 kitty 的 GLFW 分支使用的客户端协议名，
  不是启用 IBus；上游 GLFW 3.4 使用 `XMODIFIERS`；
- 本项目不使用 kitty 的 IBus 客户端；W550 使用 foot + niri，BT-7274 使用 Plasma。

注意：

- 不要用 `home.file` 递归管理整个 `~/.local/share/fcitx5/rime`；
- Rime 的 `*.userdb`、`user.yaml`、`installation.yaml`、`*.bin` 是运行时数据，不归 HM 管理；
- 皮肤如果指 fcitx5 主题，放 `xdg.dataFile."fcitx5/themes/..."`；
- Rime 的 Squirrel/Weasel 皮肤不适用于 Linux fcitx5。

## 清理旧系统与引导（谨慎）

> 目标：只保留当前可用的 generation，删除旧 profile、旧 boot entry 和不可达 store，
> 让系统接近“第一次构建”的状态。
>
> **这不是重装系统**：不会重置 `system.stateVersion`、hardware config、secrets
> 或已安装软件；只是清理历史 generation 和引导条目。
>
> **破坏性操作**：删除旧 generation 后无法再 `nixos-rebuild --rollback`。
> 请先确认当前系统能正常启动和联网，再执行下面的命令。

### 0. 备份 boot 和 profile 列表

```bash
# $(date +%F) 只是给备份文件加日期后缀
sudo mkdir -p /var/backups/nixos-cleanup
sudo cp -a /boot/loader /var/backups/nixos-cleanup/loader-$(date +%F)

# 保存 generation 和命名 profile 列表，便于出问题时对照
sudo nix-env -p /nix/var/nix/profiles/system --list-generations \
  | sudo tee /var/backups/nixos-cleanup/system-generations.txt
ls -l /nix/var/nix/profiles/system-profiles \
  | sudo tee /var/backups/nixos-cleanup/system-profiles.txt
```

### 方案 A（推荐）：统一到默认 `system` profile

`-p` 只是昵称；如果不需要命名 profile，方案 A 会让系统只保留默认 profile，
最接近第一次构建。

> 如果这次切换产生了新的 closure，建议先 `sudo reboot` 确认新系统能正常启动，
> 再执行删除和 GC。`/run/booted-system` 会保护当前 booted closure；
> 未重启时，旧 booted 系统的 store 不会被彻底回收。
> 下面以 `BT-7274` 为例；在 W550 上把主机名换成 `W550`。

```bash
# 1) 用默认 profile 构建并切换（不再带 -p）
nrb switch --flake path:.#BT-7274

# 2) 确认默认 profile 已经指向新 closure
#    readlink -f 会把软链解析成真实的 /nix/store/... 路径
readlink -f /nix/var/nix/profiles/system
nixos-version

# 3) 建议重启进入新系统后再清理
#    /run/booted-system 是当前 booted closure 的 GC root
sudo reboot

# 4) 重启后，把旧昵称设为实际用过的名字（如 niriwm/kde/flakes）
PROFILE=niriwm

# 5) 删除默认 system 的旧 generation；old 表示保留当前，删除其余
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old

# 6) 查看并删除旧命名 profile
#    先看列表，确认哪些是旧的；不要删除还在使用的 profile
ls -l /nix/var/nix/profiles/system-profiles

# 历史实验 profile 示例
sudo rm -f /nix/var/nix/profiles/system-profiles/zen-*
sudo rm -f /nix/var/nix/profiles/system-profiles/zenGPU-*

# 方案 A 不再使用命名 profile 时，删除当前昵称的 profile 和 generation 链接
sudo rm -f /nix/var/nix/profiles/system-profiles/"$PROFILE"*

# 7) 回收不可达 store
#    这一步会删除旧 generation 和旧 store 路径（包括旧明文 pre-start）
sudo nix-collect-garbage -d

# 8) 重新生成 systemd-boot 条目（只安装引导，不切换运行系统）
sudo nixos-rebuild boot --flake path:.#BT-7274

# 9) 验证并清理 EFI 分区上未被引用的文件
sudo bootctl list
sudo bootctl cleanup
```

方案 A 完成后，后续构建不带 `-p`：

```bash
nrb switch --flake path:.#BT-7274
```

### 方案 B（保留命名 profile）

如果你想继续使用 `-p "$PROFILE"`，可以保留命名 profile；
但默认 `system` 会和它指向同一个 closure，boot 菜单可能出现重复条目。

```bash
# 设定你实际使用的昵称，任意；例如 niriwm/kde/flakes
PROFILE=niriwm

# 1) 让默认 system 指向当前命名 profile 的 closure
#    readlink -f 解析 profile 软链；--set 把默认 profile 切换到该 closure
sudo nix-env -p /nix/var/nix/profiles/system \
  --set "$(readlink -f "/nix/var/nix/profiles/system-profiles/$PROFILE")"

# 2) 删除两个 profile 的旧 generation（保留当前）
sudo nix-env -p /nix/var/nix/profiles/system --delete-generations old
sudo nix-env -p "/nix/var/nix/profiles/system-profiles/$PROFILE" --delete-generations old

# 3) 删除其他旧命名 profile（按实际列表调整）
sudo rm -f /nix/var/nix/profiles/system-profiles/zen-*
sudo rm -f /nix/var/nix/profiles/system-profiles/zenGPU-*

# 4) GC 并重新生成引导
sudo nix-collect-garbage -d
nrb boot -p "$PROFILE" --flake path:.#BT-7274
sudo bootctl list
sudo bootctl cleanup
```

### 验证清理结果

```bash
# 只应看到当前 generation 和当前引导条目
sudo bootctl list
ls -l /nix/var/nix/profiles/
ls -l /nix/var/nix/profiles/system-profiles/ 2>/dev/null || true

# 旧 generation 的明文 pre-start 应已被 GC；当前 sops 版本仍会保留
# 这里只列文件名，不要打印文件内容
ls /nix/store/*-sing-box-pre-start 2>/dev/null
```

如果希望 boot 菜单只保留一个条目，可以把
[modules/system/boot.nix](modules/system/boot.nix#L13-L17) 里的
`configurationLimit` 改成 `1`；但不建议，因为会失去回滚点。

### 注意

- `nix-collect-garbage -d` 会删除所有旧 generation，执行前确认不再需要回滚。
- `/run/booted-system` 是当前启动 closure 的 GC root；如果 switch 后没有重启，
  旧 booted 系统仍会被保留，想彻底清掉旧 store 要先重启再 GC。
- 不要手动删除整个 `/boot/EFI/nixos` 或 `/boot/loader/entries`；
  让 `nixos-rebuild boot` 和 `bootctl` 管理。
- 如果 `bootctl list` 仍看到旧条目，先检查 `/boot/loader/entries`，
  不要直接 `rm -f *.conf`。
- Home Manager 的旧 generation 可选清理：
  ```bash
  home-manager generations
  home-manager expire-generations '-30 days'
  ```
- 清理不会改变 `singBox.tun = false`，也不会打开 TUN 全局代理。

## 更新依赖

```bash
env http_proxy=http://127.0.0.1:8080 \
    https_proxy=http://127.0.0.1:8080 \
    all_proxy=http://127.0.0.1:8080 \
    no_proxy=127.0.0.1,localhost,::1 \
    nix flake update
```

更新后建议先 `nix flake check path:.`，确认无误再 `nixos-rebuild switch`。

## 故障排查

### sing-box

```bash
systemctl status sing-box
sudo journalctl -u sing-box -b --no-pager | tail -80
ss -lntp | grep -E '8080|1080'
curl -x http://127.0.0.1:8080 -I https://github.com
sudo systemd-analyze security sing-box
```

如果切换后 sing-box 启动失败，优先查看日志里是否与
`ProtectSystem`、capability 或端口绑定有关；必要时回滚：

```bash
# 方案 A：默认 system profile
sudo nixos-rebuild switch --rollback

# 方案 B：命名 profile
sudo nixos-rebuild switch --rollback -p "$PROFILE"
```

### nix-daemon 代理

```bash
sudo systemctl restart nix-daemon
sudo systemctl show nix-daemon -p Environment
sudo sh -c 'tr "\0" "\n" < /proc/$(pgrep -x nix-daemon | head -1)/environ | grep -i proxy'
```

确认生成的配置：

```bash
nix --extra-experimental-features nix-command config show \
  | grep -E 'substituters|impure-env|experimental'
```

### Profile / 引导

```bash
readlink -f /nix/var/nix/profiles/system
readlink -f /nix/var/nix/profiles/system-profiles/"$PROFILE"
sudo bootctl list
sudo bootctl status
```

### SSH 登录

基类默认关闭密码登录：

- `PasswordAuthentication = false`
- `KbdInteractiveAuthentication = false`

如果你还没有可用的 SSH 密钥，先在对应 host 的 `settings.openssh` 里覆盖为 `true`，
再切换；否则会失去密码 SSH 登录能力。

### Flake 路径

出现 `hardware-configuration.nix` 不存在时，确认使用的是：

```bash
--flake path:.#W550
# 或
--flake path:.#BT-7274
```

不要用 `git+file:`，它不会包含被 `.gitignore` 忽略的硬件配置。

### TUN

TUN 是全局代理。当前 `singBox.tun = false`，TUN inbound 也是注释状态；
不要为了 Nix 构建走代理而打开它。
