{
  description = "NixOS configurations for W550 (niri) and BT-7274 (Plasma)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      # nixos-hardware 自己声明了 nixpkgs input；跟随后可避免锁两份 nixpkgs。
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 两台主机当前共用同一份加密 secret 配置。
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nixos-hardware,
      sops-nix,
      ...
    }:
    let
      # 统一的主机构建函数：每个 host 只读自己的 settings.nix。
      # 当前两台主机都使用 Home Manager。
      mkHost =
        {
          host,
          extraModules ? [ ],
        }:
        let
          settings = import ./hosts/${host}/settings.nix;
        in
        nixpkgs.lib.nixosSystem {
          system = settings.system;

          # 只把 settings 传给模块；当前没有模块使用 inputs，故不注入。
          specialArgs = { inherit settings; };

          modules =
            [
              ./hosts/${host}/default.nix
            ]
            ++ extraModules
            ++ [
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;

                  users.${settings.username} = import ./hosts/${host}/home.nix;
                  extraSpecialArgs = { inherit settings; };
                };
              }
            ];
        };
    in
    {
      nixosConfigurations = {
        W550 = mkHost {
          host = "W550";
          extraModules = [
            # Tuxedo InfinityBook Pro 14 Gen9 AMD 的硬件支持。
            nixos-hardware.nixosModules.tuxedo-infinitybook-pro14-gen9-amd
            sops-nix.nixosModules.sops
          ];
        };

        "BT-7274" = mkHost {
          host = "BT-7274";
          extraModules = [
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
