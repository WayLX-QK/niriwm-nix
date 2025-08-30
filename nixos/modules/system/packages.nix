{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [

    polkit_gnome
    fuzzel
    swaylock
    waybar
    mako
    swayidle
    swaybg

    tuigreet
    
    alacritty
    ghostty

    # brightnessctl # Screen brightness control
    # xorg.xev # Tool to capture information about button presses
    # toybox # Numerous unix command line utilities
    # siji    # Font required for polybar
    # unifont # Font required for polybar 
    
    # Network Applications:
    # Includes web browsers, email clients, FTP clients, etc.

    # Multimedia Applications:
    # Includes audio control, media players, etc.
    # pavucontrol # pulseaudio frontend
    # vlc
    # feh # image viewer to set background 

    # File Management:
    # xfce.thunar
    # ranger

    # Security Tools:
    
    # Development Tools:
    # C/C++
    gcc
    gdb

    android-tools
    docker-compose
    

    inetutils
    git
    neovim
    wget
    curl
    btop
    fastfetch
  ];
}