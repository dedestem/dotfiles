{ config, pkgs, ... }:

{
  networking.hostName = "an_laptop";

  # Configure keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "caps:escape";
  };
  console.useXkbConfig = true;

  # Flatpak service configuration
  services.flatpak.enable = true;

  # Install essential packages (system-wide)
  environment.systemPackages = with pkgs; [
    wget
    curl
    firefox
    kitty
    hyprpaper
    copyq
    wofi
    tofi
    fuzzel
    waybar
    micro
    neofetch
    neovim
    vscode
    git
    gnupg
    jq
    pinentry
  ];

  # Enable GNOME Desktop
  services.xserver.desktopManager.gnome.enable = true;

  # Enable Hyprland
  programs.hyprland.enable = true;

  system.stateVersion = "25.05";
}

