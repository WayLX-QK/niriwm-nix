{
  ...
}:
{
  programs.foot = {
    enable = true;
    server.enable = true;
  };

  # 原实现用 home.file 递归链接整个 config 目录；改为 xdg.configFile 单文件。
  # 最终仍是 ~/.config/foot/foot.ini 的软链，force 行为与原来一致。
  # 目录本身保持为真实目录，Dux Shell 仍可写入 dank-colors.ini。
  xdg.configFile."foot/foot.ini" = {
    source = ./foot.ini;
    force = true;
  };
}
