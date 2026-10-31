# 可复用：KDE Plasma 6 + SDDM（Wayland）。
{
  ...
}:
{
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    enableHidpi = true;
  };
}
