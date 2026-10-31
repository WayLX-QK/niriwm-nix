{
  pkgs,
  ...
}:
{
  hardware.steam-hardware.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Steam Remote Play
    dedicatedServer.openFirewall = true; # Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Steam 局域网游戏传输
  };

  # Steam / 游戏相关包；hardware.graphics 已移到 graphics.nix。
  environment.systemPackages = with pkgs; [
    # openvr # 原配置未启用，SteamVR 相关
    # libusb1 # 原配置未启用，VR 设备相关
    usbutils
    libsndfile
    # xwayland # 原配置未启用
    gamescope
  ];

  # 原 VR udev 规则注释保留。
  # services.udev.packages = with pkgs; [
  #   openvr
  # ];

  # services.udev.extraRules = ''
  #   # HTC Vive
  #   SUBSYSTEM=="usb", ATTR{idVendor}=="0bb4", ATTR{idProduct}=="2c87", MODE="0666", GROUP="plugdev"
  #   SUBSYSTEM=="usb", ATTR{idVendor}=="28de", ATTR{idProduct}=="2101", MODE="0666", GROUP="plugdev"
  #   SUBSYSTEM=="usb", ATTR{idVendor}=="28de", ATTR{idProduct}=="2000", MODE="0666", GROUP="plugdev"
  # '';
}
