# 所有主机共享的 Nix 配置；镜像列表由 hosts/<host>/settings.nix 提供。
{
  lib,
  settings,
  ...
}:
let
  # 端口只在 hosts/<host>/settings.nix 的 singBox.httpPort 中定义一次。
  # 这里的 or 8080 是防御性默认值：即使以后新增一台没有 singBox 配置的主机，
  # 也不会因为缺少字段而 evaluation 失败。
  proxyPort = (settings.singBox or { }).httpPort or 8080;
  proxyUrl = "http://127.0.0.1:${toString proxyPort}";

  # 代理只用于 Nix 自己的下载，不写入 environment.sessionVariables，
  # 因此不会影响桌面会话、Firefox 或其他系统服务。
  # 镜像域名直连，避免镜像流量也绕到 VPS；
  # cache.nixos.org、github.com、raw.githubusercontent.com 等不在列表中，
  # 会走代理。镜像地址变化时记得同步修改这里。
  noProxy = "127.0.0.1,localhost,::1,mirror.sjtu.edu.cn,mirrors.ustc.edu.cn,mirrors.tuna.tsinghua.edu.cn";
in
{
  nixpkgs.config.allowUnfree = true;

  # 仅给 nix-daemon 设置代理环境变量：
  # - binary cache 的 substituters 下载由 daemon 执行，会使用这些变量；
  # - 不会影响普通用户 shell、Firefox 或其他 systemd 服务；
  # - FOD（fetchurl/fetchgit 等）通过下面的 impure-env 获取代理。
  systemd.services.nix-daemon.environment = {
    http_proxy = proxyUrl;
    https_proxy = proxyUrl;
    all_proxy = proxyUrl;
    no_proxy = noProxy;
  };

  nix.settings = {
    # lib.mkForce 会强制覆盖 nixpkgs 默认的 substituters 列表，
    # 而不是在默认值后面追加。这样既避免生成重复的 cache.nixos.org，
    # 也保留 hosts settings 里的“镜像优先、官方兜底”顺序。
    substituters = lib.mkForce settings.substituters;

    # 同理，默认公钥只保留一份，避免 nix.conf 中出现重复 key。
    trusted-public-keys = lib.mkForce [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];

    # configurable-impure-env 是使用 impure-env 的前置实验特性。
    experimental-features = [ "nix-command" "flakes" "configurable-impure-env" ];

    # impure-env 只对 fixed-output derivation 生效：
    # fetchurl/fetchgit/fetchzip/goModules 等会读取这些变量；
    # 普通 build 仍然运行在无网络的 sandbox 中，这是 Nix 的设计。
    impure-env = "http_proxy=${proxyUrl} https_proxy=${proxyUrl} all_proxy=${proxyUrl} no_proxy=${noProxy}";

    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
