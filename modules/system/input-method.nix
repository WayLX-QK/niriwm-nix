# 可复用：系统级 fcitx5 + fcitx5-rime 引擎。
# 引擎、rime-ice 基础数据和 daemon 在这里；用户方案/词库/皮肤由
# modules/home/input-method/fcitx5-rime 管理。
{
  config,
  pkgs,
  ...
}:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-fluent
      (fcitx5-rime.override {
        rimeDataPkgs = [
          rime-ice
        ];
      })
    ];
  };

  # NixOS 的 i18n.inputMethod 只安装包和设置环境变量，不负责启动 daemon。
  systemd.user.services.fcitx5-daemon = {
    description = "Fcitx5 input method editor";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig.ExecStart = "${config.i18n.inputMethod.package}/bin/fcitx5";
  };
}
