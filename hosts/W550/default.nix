{
  settings,
  ...
}:
{
  imports = [
    # 宿主机生成，包含磁盘 UUID / swap 等硬件指纹，.gitignore 已忽略，不提交。
    ./hardware-configuration.nix

    # 共享系统基线。
    ../../modules/system/base.nix
    ../../modules/system/input-method.nix

    # 可复用安全/服务/图形模块。
    ../../modules/security/polkit.nix
    ../../modules/security/gnome-keyring.nix
    ../../modules/services/greetd.nix
    ../../modules/services/upower.nix
    ../../modules/services/power-profiles-daemon.nix
    ../../modules/hardware/vulkan.nix

    # W550 桌面与游戏/虚拟化功能。
    ../../modules/system/steam.nix
    ../../modules/system/bluetooth.nix
    ../../modules/desktop/niri-profile.nix
    ../../modules/virtualisation/docker.nix
    ../../modules/virtualisation/libvirtd.nix

    # 两台主机当前共用同一份 sing-box 配置。
    ../../modules/services/sing-box.nix
  ];

  # sing-box secret：两台主机共用同一份加密文件与 age key。
  sops.defaultSopsFile = ../../secrets/sing-box.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/age.key";

  system.stateVersion = settings.systemStateVersion;
}
