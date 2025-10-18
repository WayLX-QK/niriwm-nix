{ config, lib, pkgs, userSettings, ... }:
{ 
  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.name;
    extraGroups = [ "networkmanager" "wheel" "adbusers" "docker" ];# bluetooth
    packages = with pkgs; [
      firefox
      obs-studio
      # google-chrome
      ungoogled-chromium
      prismlauncher
      localsend
      vlc
      fluffychat
      
      zip
      xz
      unzip
      p7zip
      nmap

      quickshell
      ddcutil
      wl-clipboard
      gpu-screen-recorder 
      brightnessctl
      cliphist 
      matugen
      cava 
      wlsunset 
      xdg-desktop-portal
      bluez

      tuigreet

      #alacritty
      #ghostty
      openvpn
      xwayland-satellite
      
      inetutils
      neovim
      btop
      fastfetch

      gcc
      gdb

      android-tools
      docker-compose
    ];
  };
}
