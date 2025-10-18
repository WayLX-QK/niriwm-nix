{ config, lib, pkgs, ... }:
{
  # programs.niri.enable = true;
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # environment.variables = {
  # QS_ICON_THEME = "Papirus";
  # };
  home.sessionVariables = {
  #  NIXOS_OZONE_WL = "1";
    QS_ICON_THEME = "Papirus";
  };
  
  # programs.alacritty.enable = true;
  programs.fuzzel.enable = true;
  programs.swaylock.enable = true;
  # programs.waybar.enable = true;
  services.mako.enable = true;
  services.swayidle.enable = true;
  services.polkit-gnome.enable = true;
  home.packages = with pkgs; [
    # swaybg # wallpaper
    wpaperd

    papirus-icon-theme
    gnome-themes-extra
  ];


  home.file.".config/niri" = {
    recursive = true;
    source = ./config;
    target = ".config/niri";
  };

  imports = [
    ./../foot/default.nix
    ./../packages/default.nix
  ];

}

