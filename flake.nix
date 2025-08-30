{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # NOTE: change "nixpkgs" to "nixpkgs-stable" to use stable NixOS release

    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations = {
      # NOTE: change "host" to your system's hostname
      W550 = nixpkgs.lib.nixosSystem {
        modules = [
          ./nixos/modules/system/default.nix
	  nixos-hardware.nixosModules.tuxedo-pulse-14-gen3
        ];
      };
    };
  };
}
