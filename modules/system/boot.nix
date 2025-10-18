{ config, lib, pkgs, ... }:
{
  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
        consoleMode = "keep";
      };
    };
    initrd = {
      enable = true;
      systemd.enable = true;
    };
    consoleLogLevel = 3;
    plymouth = {
     enable = true;
     font = "${pkgs.source-code-pro}/share/fonts/opentype/SourceCodePro-Regular.otf";
     themePackages = [ pkgs.catppuccin-plymouth ];
     theme = "catppuccin-macchiato";
    };
  };
}