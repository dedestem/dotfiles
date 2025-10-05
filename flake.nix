{
  description = "David's dotfiles";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs, ... }:
  {
    nixosConfigurations = {
      an_laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
	modules = [
          ./hosts/an_laptop/configuration.nix
	  ./hosts/an_laptop/hardware-configuration.nix
	  ./modules/boot_x86-64-uefi.nix
	  ./modules/locals.nix
	  ./modules/common.nix
	  ./modules/security.nix
        ];
        specialArgs = { inherit self; };
      };
    };
  };
}

