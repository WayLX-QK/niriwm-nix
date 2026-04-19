{ config, lib, pkgs, ... }:
{
  fonts = {
    enableDefaultPackages = false;
    fontDir.enable = true;
    packages = with pkgs; [
      material-design-icons
      font-awesome

      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif

      nerd-fonts.symbols-only
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka

      source-sans
      source-serif
      source-code-pro

      source-han-sans
      source-han-serif
      source-han-mono

      lxgw-wenkai-screen

      maple-mono.NF-CN-unhinted
      (pkgs.callPackage ./../pkgs/harmonyos_sans.nix {})
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Noto Serif"
          "Noto Serif CJK SC"
          "Noto Serif CJK TC"
          "Source Serif 4"
          "Source Han Serif SC"
          "Source Han Serif TC"
        ];
        sansSerif = [
          "Noto Sans"
          "Noto Sans CJK SC"
          "Noto Sans CJK TC"
          "Source Sans 3"
          "LXGW WenKai Screen"
          "Source Han Sans SC"
          "Source Han Sans TC"
          "HarmonyOS Sans"
          "HarmonyOS Sans SC"
          "HarmonyOS Sans TC"
        ];
        monospace = [
          "Maple Mono NF CN"
          "JetBrainsMono Nerd Font"
          "FiraCode Nerd Font"
          "Iosevka Nerd Font"
          "Source Han Mono SC"
          "Source Han Mono TC"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
      antialias = true;
      hinting.enable = false;
      subpixel = {
        rgba = "rgb";
      };
    };
  };

  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "zh_CN.UTF-8";
      LC_IDENTIFICATION = "zh_CN.UTF-8";
      LC_MEASUREMENT = "zh_CN.UTF-8";
      LC_MONETARY = "zh_CN.UTF-8";
      LC_NAME = "zh_CN.UTF-8";
      LC_NUMERIC = "zh_CN.UTF-8";
      LC_PAPER = "zh_CN.UTF-8";
      LC_TELEPHONE = "zh_CN.UTF-8";
      LC_TIME = "zh_CN.UTF-8";
    };
  };
}
