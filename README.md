# niriwm-nix
nixos-niriwm
sudo nixos-rebuild switch -p niri --flake path:.
sudo nixos-rebuild switch --flake path:.#W550
cd /etc/nixos && sudo nix flake update && sudo nixos-rebuild switch -p niri --flake .
