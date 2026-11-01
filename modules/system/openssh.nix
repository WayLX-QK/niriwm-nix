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

      # 安全默认：只允许密钥登录。
      # 如果某台主机确实需要密码登录，在该主机的 settings.openssh 里
      # 显式覆盖 PasswordAuthentication = true，否则会失去密码 SSH 登录能力。
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    } // (settings.openssh or { });
  };
}
