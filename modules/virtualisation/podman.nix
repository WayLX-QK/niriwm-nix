# 可复用：Podman（提供 docker 兼容命令）+ distrobox。
{
  pkgs,
  ...
}:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages = with pkgs; [
    distrobox
  ];
}
