{ config, lib, pkgs, ... }: 
{
  programs.thunar.enable = true;
  programs.xfconf.enable = true;

  programs.thunar.plugins = with pkgs; [
    thunar-archive-plugin
    thunar-volman
  ];

  services.gvfs.enable = true;
  services.tumbler.enable = true;

  environment.systemPackages = with pkgs; [
    file-roller
    ffmpegthumbnailer
  ];
}
