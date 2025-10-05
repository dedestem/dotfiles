{ config, pkgs, ... }:

{
  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

  # Show something nicer than [ OK ] spam
  boot.plymouth.enable = true;
  boot.plymouth.theme = "fade-in";
  boot.kernelParams = [ "quiet" "splash" ];

  # Use the latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
