# 所有主机共享的字体配置（统一采用 BT-7274 的字体方案）。
{
  pkgs,
  ...
}:
{
  fonts = {
    packages = with pkgs; [
      inter
      lxgw-wenkai
      nerd-fonts.caskaydia-mono
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [
          "Inter"
          "Noto Sans CJK SC"
        ];
        serif = [
          "Noto Serif"
          "Noto Serif CJK SC"
        ];
        monospace = [
          "CaskaydiaMono Nerd Font"
          "LXGW WenKai Mono"
          "Noto Sans Mono CJK SC"
        ];

        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
