{ config, lib, pkgs, ... }: {
  home.packages = [
    pkgs.font-awesome
    # pkgs.material-symbols
    # pkgs.material-icons
    pkgs.jetbrains-mono
  ];
}
