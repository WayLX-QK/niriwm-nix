{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./networking.nix
    ./locale.nix
    ./services.nix
    ./desktop.nix
    ./sound.nix
    ./security.nix
    ./users.nix
    ./packages.nix
    ./virtualisation.nix
    ./nix-settings.nix
    ./hardware.nix
  ];

  system.stateVersion = "25.11";
}