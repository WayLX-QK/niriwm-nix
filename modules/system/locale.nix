# 所有主机共享的时区 / locale 基线；字体列表由各主机自行决定。
{
  settings,
  ...
}:
{
  time.timeZone = settings.timeZone;

  i18n = {
    defaultLocale = settings.defaultLocale;
    extraLocaleSettings = settings.extraLocaleSettings;
  };
}
