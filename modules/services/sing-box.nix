# 可复用：sing-box naive 代理（SOCKS + HTTP）。
#
# 配置来源于 Android 版 niko666.json；当前不启用 TUN。
# 注意：TUN + auto_route 是全局代理，会接管整台主机流量；
# 本项目只要求 Nix 构建走代理，因此 TUN 必须保持关闭。
# secret 通过 sops-nix 注入；nixpkgs 的 services.sing-box 模块会在
# ExecStartPre 中用 jq 展开配置里的 _secret，生成 /run/sing-box/config.json，
# 明文不会进入 Nix store。
#
# 注意：Nix 构建用的代理只配置给 nix-daemon（见 modules/system/nix.nix），
# 这里不设置任何全局代理，避免影响桌面、Firefox 和其他系统服务。
{
  config,
  lib,
  settings,
  ...
}:
let
  sb = settings.singBox or { };

  # 端口只在 hosts/<host>/settings.nix 的 singBox 中定义一次；
  # 这里的 or 默认值保证即使配置不完整也不会 evaluation 失败。
  httpPort = sb.httpPort or 8080;
  socksPort = sb.socksPort or 1080;

  # TUN 是全局代理：auto_route 会把整台主机的流量都接管。
  # 本项目只要求 Nix 构建走代理，因此默认关闭 TUN；
  # 只有未来明确需要全局代理时，才在 host settings 里设置 tun = true。
  tunEnabled = sb.tun or false;

  # secret 名集中在这里；hosts 只在需要覆盖时才写这些字段。
  serverSecret = sb.serverSecret or "sing-box-naive-server";
  serverNameSecret = sb.serverNameSecret or "sing-box-naive-server-name";
  usernameSecret = sb.usernameSecret or "sing-box-naive-username";
  passwordSecret = sb.passwordSecret or "sing-box-naive-password";

  secret = name: config.sops.secrets.${name}.path;
in
{
  sops.secrets.${serverSecret} = {
    key = "sing-box/naive_server";
    owner = "sing-box";
    mode = "0400";
    restartUnits = [ "sing-box.service" ];
  };
  sops.secrets.${serverNameSecret} = {
    key = "sing-box/naive_server_name";
    owner = "sing-box";
    mode = "0400";
    restartUnits = [ "sing-box.service" ];
  };
  sops.secrets.${usernameSecret} = {
    key = "sing-box/naive_username";
    owner = "sing-box";
    mode = "0400";
    restartUnits = [ "sing-box.service" ];
  };
  sops.secrets.${passwordSecret} = {
    key = "sing-box/naive_password";
    owner = "sing-box";
    mode = "0400";
    restartUnits = [ "sing-box.service" ];
  };

  services.sing-box = {
    enable = true;

    settings = {
      log = {
        level = "info";
        timestamp = true;
      };

      http_clients = [
        {
          tag = "proxy-client";
          detour = "proxy";
        }
      ];

      dns = {
        servers = [
          {
            tag = "dns-remote";
            type = "https";
            server = "1.1.1.1";
            detour = "proxy";
          }
          {
            tag = "dns-direct";
            type = "udp";
            server = "223.5.5.5";
          }
        ];

        rules = [
          {
            rule_set = "geosite-cn";
            action = "route";
            server = "dns-direct";
          }
        ];

        final = "dns-remote";
        strategy = "prefer_ipv4";
      };

      inbounds = [
        # 警告：TUN + auto_route 是全局代理，会接管整台主机的流量。
        # 本项目只要求 Nix 构建走代理，因此保持注释；不要为了让
        # nixos-rebuild 走代理而打开 TUN。只有明确需要全局代理时，
        # 才取消注释，并在 hosts settings 里设置 singBox.tun = true。
        # {
        #   type = "tun";
        #   tag = "tun-in";
        #   address = [ "172.19.0.1/30" ];
        #   auto_route = true;
        #   strict_route = true;
        # }
        {
          type = "socks";
          tag = "socks-in";
          listen = "127.0.0.1";
          listen_port = socksPort;
        }
        {
          type = "http";
          tag = "http-in";
          # 只监听回环：nix-daemon、终端工具和 Firefox 都通过
          # 127.0.0.1 上的 httpPort 使用代理。若确实需要局域网共享，
          # 应改为 0.0.0.0，并同时配置防火墙放行和 HTTP inbound users 认证。
          listen = "127.0.0.1";
          listen_port = httpPort;
        }
      ];

      outbounds = [
        {
          type = "naive";
          tag = "proxy";

          # 服务器地址、SNI、用户名、密码全部走 sops secret。
          server = { _secret = secret serverSecret; };
          server_port = 443;
          username = { _secret = secret usernameSecret; };
          password = { _secret = secret passwordSecret; };
          domain_resolver = "dns-direct";

          tls = {
            enabled = true;
            server_name = { _secret = secret serverNameSecret; };
          };
        }
        {
          type = "direct";
          tag = "direct";
        }
        {
          type = "block";
          tag = "block";
        }
      ];

      route = {
        default_domain_resolver = "dns-direct";
        default_http_client = "proxy-client";

        rules = [
          {
            protocol = "dns";
            action = "hijack-dns";
          }
          {
            network = "udp";
            port = 443;
            action = "reject";
            method = "drop";
          }
          {
            ip_is_private = true;
            outbound = "direct";
          }
          {
            rule_set = "geosite-cn";
            outbound = "direct";
          }
          {
            rule_set = "geoip-cn";
            outbound = "direct";
          }
        ];

        rule_set = [
          {
            tag = "geosite-cn";
            type = "remote";
            format = "binary";
            url = "https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set/geosite-cn.srs";
          }
          {
            tag = "geoip-cn";
            type = "remote";
            format = "binary";
            url = "https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-cn.srs";
          }
        ];

        final = "proxy";
        auto_detect_interface = true;
      };
    };
  };

  # systemd 最小加固。
  #
  # 上游 sing-box 包自带的 unit 默认授予 NET_ADMIN/NET_RAW/NET_BIND_SERVICE/
  # SYS_PTRACE/DAC_READ_SEARCH，范围偏大。
  #
  # 说明：nixpkgs 模块的 ExecStartPre 使用 "+" 前缀；systemd 会以完整 root
  # 权限执行它（不受下面的 CapabilityBoundingSet/ProtectSystem 限制），
  # 所以 sops secret 展开和 chown 仍然正常。
  #
  # 下面的 "//" 是 Nix attrset 合并：先应用通用加固，再按 TUN 开关追加
  # 对应的 capability 配置；lib.optionalAttrs 只在条件成立时返回非空 attrset。
  systemd.services.sing-box.serviceConfig = {
    NoNewPrivileges = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateTmp = true;
  }
  // lib.optionalAttrs (!tunEnabled) {
    # lib.optionalAttrs：只有条件成立时才合并这段 attrset。
    # SOCKS/HTTP 模式不需要 NET_ADMIN；但 route.auto_detect_interface
    # 可能通过 SO_BINDTODEVICE 绑定默认网卡，因此保留 CAP_NET_RAW。
    # 去掉上游的 NET_ADMIN/NET_BIND_SERVICE/SYS_PTRACE/DAC_READ_SEARCH。
    CapabilityBoundingSet = [ "CAP_NET_RAW" ];
    AmbientCapabilities = [ "CAP_NET_RAW" ];
  }
  // lib.optionalAttrs tunEnabled {
    # TUN/TProxy 需要 NET_ADMIN；NET_RAW 仍然保留给 auto_detect_interface。
    # 不要加 PrivateDevices = true，否则 /dev/net/tun 会被隐藏。
    CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
    AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
  };
}
