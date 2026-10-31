# 通用 OpenSSH 基线；主机通过 settings.openssh 覆盖/追加设置。
{
  settings,
  ...
}:
{
  services.openssh = {
    enable = true;
    openFirewall = true;

    settings = {
      PermitRootLogin = "no";
    } // (settings.openssh or { });
  };
}
