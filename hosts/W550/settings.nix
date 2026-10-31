# W550 的公共设置；可以安全提交到 Git。
# systemStateVersion 与 homeStateVersion 分开：
# - systemStateVersion 控制 NixOS 的兼容性默认值；
# - homeStateVersion 只控制 Home Manager 的兼容性默认值。
# 两者都不是“当前 NixOS 版本号”，升级前应阅读对应 release notes。
{
  system = "x86_64-linux";
  hostname = "W550";
  username = "waylx";
  fullName = "WayLX";

  systemStateVersion = "26.05";
  homeStateVersion = "26.05";

  extraGroups = [
    "networkmanager"
    "wheel"
    "adbusers"
    "docker"
    "libvirtd"
    # "bluetooth" # 原配置未启用
  ];

  timeZone = "Asia/Shanghai";
  defaultLocale = "en_US.UTF-8";

  extraLocaleSettings = {
    LC_CTYPE = "zh_CN.UTF-8";
    # 其余 LC_* 原配置即为注释，保持不启用。
    # LC_ADDRESS = "zh_CN.UTF-8";
    # LC_IDENTIFICATION = "zh_CN.UTF-8";
    # LC_MEASUREMENT = "zh_CN.UTF-8";
    # LC_MONETARY = "zh_CN.UTF-8";
    # LC_NAME = "zh_CN.UTF-8";
    # LC_NUMERIC = "zh_CN.UTF-8";
    # LC_PAPER = "zh_CN.UTF-8";
    # LC_TELEPHONE = "zh_CN.UTF-8";
    # LC_TIME = "zh_CN.UTF-8";
  };

  # 保留原 W550 的镜像顺序。
  substituters = [
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://cache.nixos.org/"
  ];

  # W550 当前没有额外开放的防火墙端口。
  firewall = {
    allowedTCPPorts = [ ];
    allowedUDPPortRanges = [ ];
  };

  # 由 modules/system/openssh.nix 合并。
  openssh = {
    X11Forwarding = true;
    PasswordAuthentication = false;
  };

  # sing-box 的 secret 名称；两台主机当前共用同一份加密配置。
  singBox = {
    serverSecret = "sing-box-naive-server";
    serverNameSecret = "sing-box-naive-server-name";
    usernameSecret = "sing-box-naive-username";
    passwordSecret = "sing-box-naive-password";
  };
}
