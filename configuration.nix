{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

networking.nameservers = [ 
 "192.168.1.248"  # 1st: Blocky (Local Cluster DNS)
  "192.168.1.141"  # 2nd: Legacy DNS Server
  "1.1.1.1"        # 3rd: Cloudflare (Public Fallback)
];
networking.dhcpcd.extraConfig = "nohook resolv.conf";
networking.networkmanager.dns = "none";
	virtualisation.docker.enable = true;
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
  

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.systemd-boot.editor = false;

  services.tailscale = {
    enable = true;
    # Declaratively set the operator user on startup
    extraUpFlags = [ "--operator=david" ];
  };

  # This forces the timeout file to literally write 0
  boot.loader.timeout = 0;

  boot.initrd.luks.devices."luks-e1191ed0-f89e-483e-ae73-adecd9779a41".device =
    "/dev/disk/by-uuid/e1191ed0-f89e-483e-ae73-adecd9779a41";
  networking.hostName = "nixos";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

  # GNOME & GDM Setup
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Remove default GNOME bloat
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-user-docs
    gnome-music
    epiphany
    geary
    evince
    totem
    snapshot
    seahorse
    showtime
    decibels

    simple-scan
    gnome-software
    gnome-logs
    gnome-connections
    gnome-text-editor

    gnome-weather
    gnome-maps
    gnome-font-viewer
    gnome-terminal
    gnome-console
    yelp
  ];

  boot.plymouth = {
    enable = true;
    themePackages = [ pkgs.adi1090x-plymouth-themes ];
    theme = "deus_ex";
  };

  # Force Plymouth to hold the screen for the LUKS passphrase entry
  boot.initrd.systemd.enable = true;

  # Keep the kernel quiet so text doesn't ruin the graphics
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];

  console.keyMap = "us";

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account.
  users.users."david" = {
    isNormalUser = true;
    description = "David";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };

  environment.sessionVariables = {
    EDITOR = "nano";
  };

  # Flatpaks
  services.flatpak.enable = true;
  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }
    {
      name = "mixtapes";
      location = "https://m-obeid.github.io/Mixtapes/mixtapes.flatpakrepo";
    }
  ];

  services.flatpak.packages = [
    {
      appId = "app.zen_browser.zen";
      origin = "flathub";
    }
    {
      appId = "com.pocoguy.Muse";
      origin = "mixtapes";
    }
    {
      appId = "org.vinegarhq.Sober";
      origin = "flathub";
    }
    {
      appId = "com.modrinth.ModrinthApp";
      origin = "flathub";
    }
    {
      appId = "be.alexandervanhee.gradia";
      origin = "flathub";
    }
  ];

  # Other programs
  services.printing.enable = true;
  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [
    micro
    tree
    wget
  ];

  # Work arounds
  system.activationScripts.forceGnomeAvatar = {
    text = ''
      mkdir -p /var/lib/AccountsService/icons
      mkdir -p /var/lib/AccountsService/users
      cp -f /home/david/.face /var/lib/AccountsService/icons/david
      chmod 644 /var/lib/AccountsService/icons/david
      echo -e "[User]\nSession=gnome\nIcon=/var/lib/AccountsService/icons/david\nSystemAccount=false\n" > /var/lib/AccountsService/users/david
    '';
  };

  # Nix configuration
  _module.args.inputs = inputs;
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10" # Required for bitwarden
  ];

  documentation.nixos.enable = false;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;
  system.stateVersion = "26.05";
}
