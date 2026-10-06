{ ... }:

{
  imports = [
    ./common.nix
    ./hardware-configuration.nix
    ./winapps.nix
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = false;
  };

  networking.hostName = "nixos-mama";
}
