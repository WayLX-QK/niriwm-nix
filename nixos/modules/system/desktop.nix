{ config, lib, pkgs, ... }:
{
  programs.niri.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # systemd.tmpfiles.rules = [
  #   "d '/var/cache/greeter' - greeter greeter - -"
  # ];

}

