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
  # 默认不额外放行端口；下面保留为模板，需要本地 Web/游戏/串流服务时再取消注释。
  firewall = {
    # allowedTCPPorts = [ 80 443 ];
    # allowedUDPPortRanges = [
    #   { from = 4000; to = 4007; }
    # ];
  };

  # 由 modules/system/openssh.nix 合并。
  openssh = {
    KbdInteractiveAuthentication = false;
    X11Forwarding = false;
  };

  # VFIO 直通：RTX 3060 给 Windows/Linux 虚拟机使用。
  # GPU 和 HDMI Audio 两个 PCI 功能都要绑定 vfio-pci；
  # 宿主机桌面使用 Arc A380（Intel），不要把 Arc 的 ID 放进来。
  vfioIds = [
    # "10de:2503" # RTX 3060 VGA
    # "10de:228e" # RTX 3060 Audio
    "1002:73df" # RX 6750 GRE VGA
    "1002:ab28" # RX 6750 GRE Audio
  ];

  # 宿主机桌面显卡：Arc A380。
  # deviceId 56a5 对应 DG2-128；i915.force_probe=!56a5 让 i915 不抢卡，
  # xe.force_probe=56a5 由 xe 驱动接管。
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

  # sing-box 的本地代理端口与运行模式。
  # 端口只在这里定义一次，modules/services/sing-box.nix 和 modules/system/nix.nix
  # 都从这里读取，避免 8080 在多处硬编码。
  #
  # 重要：TUN + auto_route 是全局代理，会接管整台主机的流量。
  # 本项目只要求 Nix 构建走代理，因此 tun 必须保持 false；
  # 不要为了让 nixos-rebuild 走代理而打开 TUN。
  #
  # secret 名称已由 modules/services/sing-box.nix 提供默认值，
  # 只有需要覆盖时才在这里写 serverSecret 等字段。
  singBox = {
    httpPort = 8080;
    socksPort = 1080;
    tun = false;
  };
}
