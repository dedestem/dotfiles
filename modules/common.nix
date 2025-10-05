{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
 
  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true; # Allow propiertary stuff!
}
