# BT-7274 的公共设置；可以安全提交到 Git。
{
  system = "x86_64-linux";
  hostname = "BT-7274";
  username = "rainy";
  fullName = "RainY";

  # system 与 HM 的兼容性默认值分开；两者都不是 NixOS 版本号。
  systemStateVersion = "26.05";
  homeStateVersion = "26.05";

  extraGroups = [
    "networkmanager"
    "wheel"
    "libvirtd"
    "kvm"
  ];

  timeZone = "Asia/Shanghai";
  defaultLocale = "en_US.UTF-8";

  extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # 保留原 BT-7274 的镜像顺序。
  substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://cache.nixos.org"
  ];

  # 由 modules/system/networking.nix 合并。
  firewall = {
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPortRanges = [
      { from = 4000; to = 4007; }
    ];
  };

  # 由 modules/system/openssh.nix 合并。
  openssh = {
    KbdInteractiveAuthentication = false;
    X11Forwarding = false;
  };

  # VFIO 直通设备；PCI ID 属于主机硬件信息。
  vfioIds = [
    "1002:73df" # RX 6750 GRE VGA
    "1002:ab28" # RX 6750 GRE Audio
    # "10de:2503" # RTX 3060 VGA
    # "10de:228e" # RTX 3060 Audio
  ];

  # Intel 核显的 PCI device id；用于 i915/xe force_probe。
  intelGpu = {
    enable = true;
    deviceId = "56a5";
  };

  # QMK/VIA 键盘的 vendor/product id；由 modules/hardware/qmk.nix 生成 udev 规则。
  qmkDevices = [
    {
      vendor = "fffe";
      product = "0009"; # monsgeek M3
    }
    {
      vendor = "fffe";
      product = "000c"; # akko 5087
    }
  ];

  # sing-box 的 secret 名称；实际值在加密的 secrets/sing-box.yaml 中。
  singBox = {
    serverSecret = "sing-box-naive-server";
    serverNameSecret = "sing-box-naive-server-name";
    usernameSecret = "sing-box-naive-username";
    passwordSecret = "sing-box-naive-password";
  };
}
