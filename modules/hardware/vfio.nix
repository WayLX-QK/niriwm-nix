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

  boot.extraModprobeConfig = ''
    softdep amdgpu pre: vfio-pci
    softdep nouveau pre: vfio-pci
    softdep nvidia pre: vfio-pci
  '';

  # 只有 VFIO 主机才需要这些 QEMU 设置。
  virtualisation.libvirtd.qemu = {
    package = pkgs.qemu_kvm;
    runAsRoot = true;
    swtpm.enable = true;
  };
}
