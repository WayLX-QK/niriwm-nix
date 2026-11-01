# 可复用：VFIO/GPU 直通的内核参数、modprobe 规则与 libvirt QEMU 设置。
# 具体 PCI ID 放在 hosts/<host>/settings.nix 的 vfioIds 中。
{
  lib,
  pkgs,
  settings,
  ...
}:
let
  vfioIds = settings.vfioIds or [ ];
in
{
  # B550M + Ryzen 5700X：开启 AMD-Vi/IOMMU；iommu=pt 是直通友好模式。
  boot.kernelParams = [
    "amd_iommu=on"
    "iommu=pt"
  ]
  ++ lib.optional (vfioIds != [ ]) ("vfio-pci.ids=" + lib.concatStringsSep "," vfioIds);

  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];

  # 本机宿主机桌面显卡是 Arc A380（Intel），没有 AMD GPU；
  # 因此只让 vfio-pci 抢在 nouveau/nvidia 之前绑定 RTX 3060。
  # 如果以后换了 AMD 显卡做直通，再补 softdep amdgpu pre: vfio-pci。
  boot.extraModprobeConfig = ''
    softdep nouveau pre: vfio-pci
    softdep nvidia pre: vfio-pci
    softdep amdgpu pre: vfio-pci
  '';

  # 只有 VFIO 主机才需要这些 QEMU 设置。
  # 注意：runAsRoot = true 会让 QEMU 以 root 运行，权限较大；
  # VFIO 直通在部分配置下需要它，请确保虚拟机来源可信。
  # 如果确认不需要，可改为 false 并测试直通是否正常。
  virtualisation.libvirtd.qemu = {
    package = pkgs.qemu_kvm;
    runAsRoot = true;
    swtpm.enable = true;
  };
}
