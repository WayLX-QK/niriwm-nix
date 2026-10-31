# 可复用：Vulkan 运行时与工具。
{
  pkgs,
  ...
}:
{
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    vulkan-loader
    vulkan-tools
  ];
}
