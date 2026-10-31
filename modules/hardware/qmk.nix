# 可复用：QMK/VIA 键盘支持。
# 设备 vendor/product id 由 settings.qmkDevices 提供，自动生成 udev 规则。
{
  lib,
  pkgs,
  settings,
  ...
}:
let
  devices = settings.qmkDevices or [ ];
  rules = lib.concatMapStrings (
    d: ''
      SUBSYSTEM=="usb", ATTR{idVendor}=="${d.vendor}", ATTR{idProduct}=="${d.product}", MODE="0666", TAG+="uaccess"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="${d.vendor}", ATTRS{idProduct}=="${d.product}", MODE="0666", TAG+="uaccess"
    ''
  ) devices;
in
{
  hardware.keyboard.qmk.enable = true;

  services.udev.packages = [
    pkgs.via
  ];

  services.udev.extraRules = rules;

  environment.systemPackages = with pkgs; [
    usbutils
  ];
}
