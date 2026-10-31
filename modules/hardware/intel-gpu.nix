# 可复用：Intel 核显 + VA-API 配置。
# 由 settings.intelGpu 驱动；没有 intelGpu 的主机不会加载本模块。
{
  lib,
  pkgs,
  settings,
  ...
}:
let
  gpu = settings.intelGpu or {
    enable = false;
    deviceId = "";
  };
in
lib.mkIf gpu.enable {
  boot.kernelParams = [
    "i915.force_probe=!${gpu.deviceId}"
    "xe.force_probe=${gpu.deviceId}"
  ];

  boot.initrd.kernelModules = [ "xe" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };

  hardware.enableRedistributableFirmware = true;
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
}
