{ config, lib, pkgs, userSettings, ... }:
{ 
  users.users.${userSettings.username} = {
    isNormalUser = true;
    description = userSettings.name;
    extraGroups = [ "networkmanager" "wheel" "adbusers" "docker" "libvirtd" ];# bluetooth
    packages = with pkgs; [
      firefox-esr
      obs-studio
      # google-chrome
      # ungoogled-chromium
      qutebrowser
      prismlauncher
      localsend
      imv
      mpv
      #vlc
      fluffychat
      
      zip
      xz
      unzip
      p7zip
      nmap

      ddcutil
      wl-clipboard
      gpu-screen-recorder 
      brightnessctl
      cliphist 
      matugen
      cava 
      wlsunset 
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
      
      s-tui
      stress
      dmidecode

      gcc
      gdb

      android-tools
      docker-compose
    ];
  };
}
