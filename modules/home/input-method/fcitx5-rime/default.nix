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

  # 用户会话变量；XMODIFIERS/QT_PLUGIN_PATH 由系统级 input-method 提供。
  home.sessionVariables = {
    GLFW_IM_MODULE = "ibus";
    SDL_IM_MODULE = "fcitx";
  };
}
