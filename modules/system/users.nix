# 所有主机共享的用户身份基线；用户包统一放在 Home Manager。
{
  settings,
  ...
}:
{
  users.users.${settings.username} = {
    isNormalUser = true;
    description = settings.fullName;
    extraGroups = settings.extraGroups;
  };
}
