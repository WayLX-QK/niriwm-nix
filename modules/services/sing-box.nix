# 可复用：sing-box naive 代理（SOCKS + HTTP）。
#
# 配置来源于 Android 版 niko666.json；当前不启用 TUN，避免修改系统路由。
# secret 通过 sops-nix 注入，sing-box 的 _secret 机制会在服务启动时
# 把 /run/secrets/... 的内容替换进运行时 config.json，不会进入 Nix store。
{
  config,
  settings,
  ...
}:
let
  sb = settings.singBox;
  secret = name: config.sops.secrets.${name}.path;
in
{
  sops.secrets.${sb.serverSecret} = {
    key = "sing-box/naive_server";
    owner = "sing-box";
    mode = "0400";
    restartUnits = [ "sing-box.service" ];
  };
  sops.secrets.${sb.serverNameSecret} = {
    key = "sing-box/naive_server_name";
    owner = "sing-box";
    mode = "0400";
    restartUnits = [ "sing-box.service" ];
  };
  sops.secrets.${sb.usernameSecret} = {
    key = "sing-box/naive_username";
    owner = "sing-box";
    mode = "0400";
    restartUnits = [ "sing-box.service" ];
  };
  sops.secrets.${sb.passwordSecret} = {
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
        # 完整 TUN 配置暂时禁用；需要全局路由时取消注释，
        # 并同时启用文件末尾的 CAP_NET_ADMIN/CAP_NET_RAW 配置。
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
          listen_port = 1080;
        }
        {
          type = "http";
          tag = "http-in";
          # 原 Android 配置为 0.0.0.0；NixOS 防火墙默认未放行 8080。
          # 只需本机代理时可改成 127.0.0.1。
          listen = "0.0.0.0";
          listen_port = 8080;
        }
      ];

      outbounds = [
        {
          type = "naive";
          tag = "proxy";

          # 服务器地址、SNI、用户名、密码全部走 sops secret。
          server = { _secret = secret sb.serverSecret; };
          server_port = 443;
          username = { _secret = secret sb.usernameSecret; };
          password = { _secret = secret sb.passwordSecret; };
          domain_resolver = "dns-direct";

          tls = {
            enabled = true;
            server_name = { _secret = secret sb.serverNameSecret; };
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

  # nix-daemon 通过本地 HTTP inbound 访问 VPS，保持原有的代理更新能力。
  systemd.services.nix-daemon.environment = {
    http_proxy = "http://127.0.0.1:8080";
    https_proxy = "http://127.0.0.1:8080";
  };

  # TUN 模式启用时再取消注释；SOCKS/HTTP 模式不需要这些 capability。
  # systemd.services.sing-box.serviceConfig = {
  #   AmbientCapabilities = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
  #   CapabilityBoundingSet = [ "CAP_NET_ADMIN" "CAP_NET_RAW" ];
  # };
}
