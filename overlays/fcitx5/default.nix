# 为了不使用默认的 rime-data，改用我自定义的小鹤音形数据，这里需要 override
# 参考 https://github.com/NixOS/nixpkgs/blob/e4246ae1e7f78b7087dce9c9da10d28d3725025f/pkgs/tools/inputmethods/fcitx5/fcitx5-rime.nix
self: super:
let
  rime-data-flypy = self.runCommandCC "rime-data-flypy" {
    meta.mainProgram = "rime-data-flypy";
  } (''
    mkdir -p $out/share/rime-data
    cp -r ${./rime-data-flypy}/* $out/share/rime-data/
  '');
in {
  fcitx5-rime = super.fcitx5-rime.override { rimeDataPkgs = [ rime-data-flypy ]; };
}
