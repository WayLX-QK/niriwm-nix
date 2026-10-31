{
  pkgs,
  ...
}:
{
  # 使用 systemd-boot EFI 引导。
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
        consoleMode = "keep";
      };
    };
    initrd = {
      enable = true;
      # 注意：最新 nixpkgs 已移除 scripted initrd，systemd initrd 成为唯一实现；
      # 旧的 boot.initrd.systemd.enable 选项已被删除，不能再设置。
    };
    consoleLogLevel = 3;
    plymouth = {
      enable = true;
      font = "${pkgs.source-code-pro}/share/fonts/opentype/SourceCodePro-Regular.otf";
      themePackages = [ pkgs.catppuccin-plymouth ];
      theme = "catppuccin-macchiato";
    };
  };
}
