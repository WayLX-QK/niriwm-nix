# 可复用：greetd + tuigreet，登录后启动 niri-session。
{
  pkgs,
  ...
}:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --remember --asterisks --no-xsession-wrapper --cmd niri-session";
      };
    };
  };
}
