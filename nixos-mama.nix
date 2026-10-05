{ ... }:

{
  imports = [
    ./common.nix
    ./hardware-configuration.nix
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
  networking.hostName = "nixos-mama";
}
