# BT-7274 的 Home Manager 入口；桌面由 system 级 Plasma 提供，这里只放用户级内容。
{
  ...
}:
{
  imports = [
    ../../modules/home/common.nix
    ../../modules/home/input-method/fcitx5-rime/default.nix
    ./home-packages.nix
  ];
}
