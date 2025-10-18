{
  description = "​Who_am_I";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nixos-hardware, ... }:
  let
    systemSettings = {
      system = "x86_64-linux";
      hostname = "W550";
      version = "25.11";
    };
    userSettings = {
      username = "waylx";
      name = "WayLX";
      dotfilesDir = "~/.wayos";
    };

    pkgs = nixpkgs.legacyPackages.${systemSettings.system};
  in {
    nixosConfigurations.${systemSettings.hostname} = nixpkgs.lib.nixosSystem {
      system = systemSettings.system;
      modules = [
        ./hosts/W550/default.nix
        nixos-hardware.nixosModules.tuxedo-infinitybook-pro14-gen9-amd
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.${userSettings.username} = import ./hosts/W550/home.nix;
          home-manager.extraSpecialArgs = {
            inherit inputs systemSettings userSettings;
          };
        }
      ];
      specialArgs = {
        inherit inputs systemSettings userSettings;
      };
    };
  };
}
