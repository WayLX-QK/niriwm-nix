# 通用网络配置：hostName 与防火墙端口来自 settings。
{
  settings,
  ...
}:
{
  networking = {
    hostName = settings.hostname;
    networkmanager.enable = true;

    firewall = {
      enable = true;
    } // (settings.firewall or { });
  };
}
