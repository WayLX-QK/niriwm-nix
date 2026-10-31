# 可复用：libvirt/QEMU + virt-manager + SPICE USB 重定向。
# 主机可以继续追加 virtualisation.libvirtd.qemu.* 等专属设置。
{
  ...
}:
{
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;
}
