{
  pkgs,
  settings,
  ...
}:
{
  imports = [
    # 宿主机生成，包含磁盘 UUID / swap 等硬件指纹，.gitignore 已忽略，不提交。
    ./hardware-configuration.nix

    # 硬件能力模块（VFIO 先于 Intel，保持原 initrd 模块顺序）。
    ../../modules/hardware/vfio.nix
    ../../modules/hardware/intel-gpu.nix
    ../../modules/hardware/qmk.nix

    # 可复用系统/桌面/输入法/虚拟化/代理模块。
    ../../modules/system/base.nix
    ../../modules/system/input-method.nix
    ../../modules/desktop/plasma.nix
    ../../modules/virtualisation/libvirtd.nix
    ../../modules/virtualisation/podman.nix
    ../../modules/services/sing-box.nix
  ];

  # sing-box secret：两台主机共用同一份加密文件与 age key。
  sops.defaultSopsFile = ../../secrets/sing-box.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/age.key";

  boot.kernelPackages = pkgs.linuxPackages_zen;

  # 打印机驱动是主机专属的；服务的 enable 在 modules/system/printing.nix。
  services.printing.drivers = with pkgs; [
    cups-brother-hl2260d
    # cups-filters
    # cups-browsed
  ];

  # base 已包含 git/wget/curl；这里只放 BT-7274 额外需要的系统工具。
  environment.systemPackages = with pkgs; [
    pciutils
    lshw
    neovim
    fastfetch
    btop
  ];

  system.stateVersion = settings.systemStateVersion;
}
