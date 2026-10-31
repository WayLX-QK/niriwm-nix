# 所有主机共享的系统基线。
# 主机只在此基础上追加桌面、硬件、服务差异，不要在这里写主机专属配置。
{
  imports = [
    ./boot.nix
    ./locale.nix
    ./networking.nix
    ./nix.nix
    ./packages.nix
    ./sound.nix
    ./fonts.nix
    ./openssh.nix
    ./printing.nix
    ./flatpak.nix
    ./users.nix
  ];
}
