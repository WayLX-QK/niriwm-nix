{ config, lib, pkgs, ... }:
{

  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
  };

  programs.niri.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # systemd.tmpfiles.rules = [
  #   "d '/var/cache/greeter' - greeter greeter - -"
  # ];

}

