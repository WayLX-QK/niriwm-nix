{
  ...
}:
{
  # 只负责 niri 本身；桌面 shell 见 dux-shell.nix。
  programs.niri.enable = true;

  # Wayland 下 Electron/Chromium 应用使用 Ozone。
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
