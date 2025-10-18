{ inputs, pkgs, systemSettings, userSettings, ... }: {
  imports = [
    ./../../modules/user/niri/default.nix
    # ./../../modules/user/packages.nix
  ];

  home = {
    username = userSettings.username;
    homeDirectory = "/home/"+userSettings.username;
    stateVersion = systemSettings.version;
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
}
