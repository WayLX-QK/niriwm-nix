{
  ...
}:
{
  # 递归链接壁纸目录；target 默认就是属性名，原配置里重复写了一次，这里省略。
  home.file."Pictures/wallpapers" = {
    recursive = true;
    source = ./images;
  };
}
