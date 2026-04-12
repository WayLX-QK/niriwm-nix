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
      
      nerd-fonts.symbols-only # symbols icon only
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      
      source-sans
      source-serif

      source-code-pro
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
        ];
        sansSerif = [
          "Noto Sans"
          "HarmonyOS Sans"
          "HarmonyOS Sans SC"
          "HarmonyOS Sans TC"
        ];
        monospace = [
          "Maple Mono NF CN"
          "HarmonyOS Sans SC"
          "HarmonyOS Sans TC"
          "JetBrainsMono Nerd Font"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
      antialias = true; # 抗锯齿
      hinting.enable = false; # 禁止字体微调 - 高分辨率下没这必要
      subpixel = {
        rgba = "rgb"; # IPS 屏幕使用 rgb 排列
      };
    };
  };

  # # all fonts are linked to /nix/var/nix/profiles/system/sw/share/X11/fonts
  # fonts = {
  #   # use fonts specified by user rather than default ones
  #   enableDefaultPackages = false;
  #   fontDir.enable = true;

  #   # fonts are defined in /modules/base/fonts.nix, used by both NixOS & Darwin.
  #   # packages = [ ... ];

  #   fontconfig = {
  #     # User defined default fonts
  #     # https://catcat.cc/post/2021-03-07/
  #     defaultFonts = {
  #       serif = [
  #         # 西文: 衬线字体（笔画末端有修饰(衬线)的字体，通常用于印刷。）
  #         "Source Serif 4"
  #         # 中文: 宋体（港台称明體）
  #         "Source Han Serif SC" # 思源宋体
  #         "Source Han Serif TC"
  #       ];
  #       # SansSerif 也简写做 Sans, Sans 在法语中就是「without」或者「无」的意思
  #       sansSerif = [
  #         # 西文: 无衬线字体（指笔画末端没有修饰(衬线)的字体，通常用于屏幕显示）
  #         "Source Sans 3"
  #         # 中文: 黑体
  #         "LXGW WenKai Screen" # 霞鹜文楷 屏幕阅读版
  #         "Source Han Sans SC" # 思源黑体
  #         "Source Han Sans TC"
  #       ];
  #       # 等宽字体
  #       monospace = [
  #         # 中文
  #         "Maple Mono NF CN" # 中英文宽度完美 2:1 的字体
  #         "Source Han Mono SC" # 思源等宽
  #         "Source Han Mono TC"
  #         # 西文
  #         "JetBrainsMono Nerd Font"
  #       ];
  #       emoji = [ "Noto Color Emoji" ];
  #     };
  #     antialias = true; # 抗锯齿
  #     hinting.enable = false; # 禁止字体微调 - 高分辨率下没这必要
  #     subpixel = {
  #       rgba = "rgb"; # IPS 屏幕使用 rgb 排列
  #     };
  #   };
  # };

  i18n.inputMethod = {
   type = "fcitx5";
   enable = true;
   fcitx5.waylandFrontend = true;
   fcitx5.addons = with pkgs; [
     # fcitx5-chinese-addons
     fcitx5-rime
     fcitx5-nord
     fcitx5-pinyin-zhwiki
     fcitx5-pinyin-moegirl
     fcitx5-pinyin-minecraft
   ];
  };

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.

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
