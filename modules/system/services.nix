{ config, lib, pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --remember  --asterisks --no-xsession-wrapper --cmd niri-session";
        # user = "greeter";
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
  # services.tlp = {
  #       enable = true;
  #       settings = {
  #         CPU_SCALING_GOVERNOR_ON_AC = "performance";
  #         CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  
  #         CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  #         CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
  
  #         CPU_MIN_PERF_ON_AC = 0;
  #         CPU_MAX_PERF_ON_AC = 100;
  #         CPU_MIN_PERF_ON_BAT = 0;
  #         CPU_MAX_PERF_ON_BAT = 20;
  
  #        #Optional helps save long term battery health
  #        START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge
  #        STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
  
  #       };
  # };
}