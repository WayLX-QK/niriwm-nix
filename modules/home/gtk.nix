{
  config,
  pkgs,
  ...
}:
{
  # 从原 niri 模块拆出：GTK 主题与 niri 本身无关。
  gtk = {
    enable = true;

    # Wayland 下仍让 GTK 应用使用 fcitx 输入法前端。
    gtk2.extraConfig = ''gtk-im-module="fcitx"'';
    gtk3.extraConfig.gtk-im-module = "fcitx";
    gtk4.extraConfig.gtk-im-module = "fcitx";

    # GTK4 沿用 GTK3 的主题配置。
    gtk4.theme = config.gtk.theme;

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };
}
