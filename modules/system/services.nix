{ config, lib, pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --remember  --asterisks --no-xsession-wrapper --cmd niri-session";
      };
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no"; # disable root login
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };

  services.flatpak.enable = true;
  services.printing.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
}