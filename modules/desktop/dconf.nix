{
  ...
}:
{
  # 原 modules/system/hardware.nix 的内容其实只有 dconf；
  # 它属于桌面/GTK 集成，因此移到 desktop 层。
  programs.dconf.enable = true;
}
