{
  pkgs,
  ...
}:
{
  # 从 modules/system/xdg.nix 移到桌面层：portal 属于桌面会话。
  xdg.portal = {
    enable = true;

    config = {
      # common.default = "*";
      common = {
        default = [ "gnome" "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
        "org.freedesktop.impl.portal.RemoteDesktop" = "gnome";
      };
    };

    xdgOpenUsePortal = true;

    extraPortals = with pkgs; [
      # 原配置保留了基础 portal，虽然 NixOS 默认也会加入；保持 1:1。
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      # Niri 使用 GNOME portal 实现屏幕共享/截图。
      xdg-desktop-portal-gnome
    ];
  };
}
