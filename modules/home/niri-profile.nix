# W550 的 Home Manager 桌面组合：GTK + niri + foot + wallpapers。
# fcitx5-rime 用户配置由两台主机共享，放在 modules/home/input-method/fcitx5-rime。
{
  imports = [
    ./gtk.nix
    ./niri/default.nix
    ./foot/default.nix
    ./wallpapers/default.nix
  ];
}
