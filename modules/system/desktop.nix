{ config, lib, pkgs, ... }:
{
  programs.niri.enable = true;
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  environment.variables = {
  QS_ICON_THEME = "Papirus";
  };
  
}

