{
  ...
}:
{
  # 从原 sound.nix 拆出，避免蓝牙与音频配置混在一起。
  hardware.bluetooth.enable = true;

  # 原配置中的 dbus 注释保留；NixOS 默认已启用 D-Bus。
  # dbus.enable = true;
  # dbus.packages = with pkgs; [ bluez ];
}
