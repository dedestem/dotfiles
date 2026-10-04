{ ... }:

{
  imports = [
    ./common.nix
    ./hardware-configuration-LAPTOP-PAPA.nix
  ];

  networking.hostName = "nixos-papa";

  services.tlp.enable = true;

  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 0;

    PCIE_ASPM_ON_AC = "performance";
    PCIE_ASPM_ON_BAT = "powersave";
  };

  # LETOP! DOE BIJ STEAM DE LAUNCH OPTIONS nvidia-offload ervoor anders dan uh lagged alles dood
  services.power-profiles-daemon.enable = false;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];
}
