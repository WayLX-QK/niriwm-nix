{ config, lib, pkgs, ... }:
{
  networking.hostName = "W550"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Enable networking
  networking.networkmanager.enable = true;
  
  networking.firewall = {
    enable = true;
    # allowedTCPPorts = [ 8080 443 ];
    # allowedUDPPortRanges = [
    #  { from = 4000; to = 4007; }
    #  { from = 8000; to = 8010; }
    # ];
  };
}