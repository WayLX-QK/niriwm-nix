{ config, lib, pkgs, systemSettings, userSettings, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/system/boot.nix
    ./../../modules/system/desktop.nix
    ./../../modules/system/networking.nix
    ./../../modules/system/locale.nix
    ./../../modules/system/services.nix
    ./../../modules/system/sound.nix
    ./../../modules/system/security.nix
    ./../../modules/system/users.nix
    ./../../modules/system/packages.nix
    ./../../modules/system/virtualisation.nix
    ./../../modules/system/nix-settings.nix
    ./../../modules/system/hardware.nix
  ];

  system.stateVersion = systemSettings.version;
}