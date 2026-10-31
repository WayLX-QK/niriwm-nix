{
  pkgs,
  ...
}:
{
  # 2026-10 的 nixos-unstable 已把 DMS (DankMaterialShell) 2.0 重命名为 Dux Shell。
  # 旧 programs.dms-shell 的以下选项已被上游删除，不能再使用：
  #   enableSystemMonitoring / enableVPN / enableDynamicTheming /
  #   enableAudioWavelength / enableCalendarEvents / enableClipboardPaste
  #
  # 对应关系：
  # - system monitoring / clipboard paste：新版本已内置，不再需要 dgop/wtype。
  # - dynamic theming / audio wavelength：模块默认安装 matugen/cava。
  # - VPN：改为运行时检测，NetworkManager 已由 networking.nix 启用。
  # - calendar events：新模块不再自动安装后端，需要自己补 khal（见下）。
  programs.dux-shell = {
    enable = true;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };
  };

  # 旧 enableCalendarEvents = true 会自动安装 khal。
  # 为保持日历事件功能 1:1，这里显式补回；如果不需要日历事件可删掉本行。
  environment.systemPackages = [ pkgs.khal ];
}
