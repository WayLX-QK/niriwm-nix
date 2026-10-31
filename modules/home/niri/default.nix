{
  ...
}:
{
  # Dux Shell / Quickshell 使用的图标主题。
  home.sessionVariables = {
    QS_ICON_THEME = "Papirus";
  };

  # niri 会话中的 polkit 认证代理。
  services.polkit-gnome.enable = true;

  # force = true：每次 rebuild 覆盖，避免 niri 运行时改文件造成冲突（原行为）。
  xdg.configFile."niri/config.kdl" = {
    source = ./config.kdl;
    force = true;
  };
}
