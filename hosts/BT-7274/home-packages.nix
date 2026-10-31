# BT-7274 用户级软件包（Home Manager 管理）。
{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    ungoogled-chromium
    zip
    xz
    unzip
    p7zip
  ];
}
