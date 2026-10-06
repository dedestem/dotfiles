{
  description = "NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    antigravity-nix = {
      url = "github:jacopone/antigravity-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Claude Desktop package (official build, with Cowork support)
    # Not following our nixpkgs: llm-agents.nix pins nixpkgs-unstable and its
    # package set fails to evaluate against other nixpkgs versions (an
    # unrelated package, git-surgeon, breaks the shared packages.<system> set).
    llm-agents-nix.url = "github:numtide/llm-agents.nix";
    # Real Microsoft Office via a Windows VM shown as seamless Linux windows
    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-flatpak,
      ...
    }@inputs:
    let
      mkHost =
        hostModule:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          # 💡 This passes inputs down to the host/common modules
          specialArgs = { inherit inputs; };

          modules = [
            nix-flatpak.nixosModules.nix-flatpak
            hostModule

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";

              home-manager.extraSpecialArgs = { inherit inputs; };

              home-manager.users.david = {
                imports = [ ./home.nix ];
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        nixos-papa = mkHost ./nixos-papa.nix;
        nixos-mama = mkHost ./nixos-mama.nix;
      };
    };
}
