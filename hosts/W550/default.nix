{ config, lib, pkgs, systemSettings, userSettings, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/system/boot.nix
    ./../../modules/system/desktop.nix
    ./../../modules/system/desktop_thunar.nix
    ./../../modules/system/networking.nix
    ./../../modules/system/locale.nix
    ./../../modules/system/services.nix
    ./../../modules/system/sound.nix
    ./../../modules/system/security.nix
    ./../../modules/system/steam.nix
    ./../../modules/system/users.nix
    ./../../modules/system/packages.nix
    ./../../modules/system/virtualisation.nix
    ./../../modules/system/nix-settings.nix
    ./../../modules/system/hardware.nix
    ./../../modules/system/xdg.nix
  ];

  system.stateVersion = systemSettings.version;
}