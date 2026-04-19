{ config, lib, pkgs, ... }:
{
  home.sessionVariables = {
    QS_ICON_THEME = "Papirus";
  };
  
  services.polkit-gnome.enable = true;

  gtk = {
    enable = true;
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

  xdg.configFile = { 
    "niri/config.kdl" = {
      source = ./config/config.kdl;
      force = true;
    };
  };

  imports = [
    ./../fcitx5/default.nix
    ./../foot/default.nix
    ./../packages/default.nix
    ./../wallpapers/default.nix
  ];

}

