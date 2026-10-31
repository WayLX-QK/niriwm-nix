# 所有使用 Home Manager 的主机共享的身份/激活基线。
{
  settings,
  ...
}:
{
  home = {
    username = settings.username;
    homeDirectory = "/home/${settings.username}";
    stateVersion = settings.homeStateVersion;
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
}
