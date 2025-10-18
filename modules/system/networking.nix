{ config, lib, pkgs, systemSettings, ... }:
{
  networking = {
    hostName = systemSettings.hostname;
    networkmanager.enable = true;
  };
  
  networking.firewall = {
    enable = true;
    # allowedTCPPorts = [ 8080 443 ];
    # allowedUDPPortRanges = [
    #  { from = 4000; to = 4007; }
    #  { from = 8000; to = 8010; }
    # ];
  };
}