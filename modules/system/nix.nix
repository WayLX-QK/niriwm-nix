# 所有主机共享的 Nix 配置；镜像列表由 hosts/<host>/settings.nix 提供。
{
  settings,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    substituters = settings.substituters;
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
