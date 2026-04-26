{ config, pkgs, ... }: {
  home.file."Pictures/wallpapers" = {
    recursive = true;
    source = ./images;
    target = "Pictures/wallpapers";
  };
}
