# 共享的 fcitx5-rime 用户配置。
# 引擎、rime-ice 基础数据和 fcitx5 daemon 由 modules/system/input-method.nix 管理；
# 这里只管理 $XDG_CONFIG_HOME/$XDG_DATA_HOME 下的用户级文件。
{
  ...
}:
{
  xdg.configFile."fcitx5/profile" = {
    source = ./profile;
    # fcitx5 每次切换输入法都会改写 ~/.config/fcitx5/profile，
    # 因此每次 rebuild 强制替换，避免文件冲突（原行为）。
    force = true;
  };

  xdg.dataFile."fcitx5/rime/default.custom.yaml" = {
    source = ./rime/default.custom.yaml;
    force = true;
  };

  # 用户会话变量；系统级 i18n.inputMethod 会设置 XMODIFIERS 和 QT_PLUGIN_PATH。
  #
  # 注意：当前 fcitx5.waylandFrontend = true，所以 NixOS 不会设置
  # GTK_IM_MODULE/QT_IM_MODULE；Wayland 原生应用走 text-input 协议，
  # XWayland 应用通过 XMODIFIERS/XIM 使用 fcitx5。
  # 如果某个 XWayland 的 GTK/Qt 应用无法输入中文，再针对该应用设置
  # GTK_IM_MODULE=fcitx / QT_IM_MODULE=fcitx，不要全局强加。
  #
  # 本项目只使用 fcitx5-rime（rime-ice），不使用 IBus；
  # 不设置 GLFW_IM_MODULE=ibus：它只是 kitty 的 GLFW 分支使用的客户端协议名，
  # 不是启用 IBus；上游 GLFW 3.4 使用 XMODIFIERS。
  # 本项目不使用 kitty 的 IBus 客户端；W550 使用 foot + niri，BT-7274 使用 Plasma。
  home.sessionVariables = {
    SDL_IM_MODULE = "fcitx";
  };
}
