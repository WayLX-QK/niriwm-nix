{ config, lib, pkgs, ... }:
{
  users.users.waylx = {
    isNormalUser = true;
    description = "WayLX";
    extraGroups = [ "networkmanager" "wheel" "adbusers" "docker" ];
    packages = with pkgs; [
      firefox
      prismlauncher
      localsend
      zip
      xz
      unzip
      p7zip
      nmap
    ];
  };
}