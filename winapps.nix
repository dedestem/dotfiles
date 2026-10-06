# WinApps: real Microsoft Office (Word, Excel, ...) on NixOS.
#
# How it works
#   A Windows 11 VM runs inside a Docker container (dockur/windows, it downloads
#   the ISO itself). WinApps connects to it over RDP and shows each Office app as
#   a normal window with its own entry in the app menu. Your home folder is
#   shared into Windows as \\host.lan\Data.
#
# Why docker compose and not virtualisation.oci-containers
#   WinApps starts / pauses / resumes the VM with
#   `docker compose --file ~/.config/winapps/compose.yaml ...`. That only works
#   on a container created by that compose file, so compose.yaml is generated
#   below and the container is created with `docker compose up -d` (once).
#
# Keeping it out of the background (RAM)
#   - AUTOPAUSE (winapps.conf): after AUTOPAUSE_TIME seconds without an open
#     Office window WinApps *pauses* the VM. That freezes the CPU, but the VM's
#     RAM (8G) stays reserved. Opening an app resumes it in about a second.
#   - winapps-autostop (user timer below): if the VM is still paused, shut
#     Windows down so the RAM is freed too. Opening an app boots it again
#     (~30-60 s). The VM is never started at boot, only when you open an app.
#   So: open Word -> VM boots/resumes; close Word -> paused after 5 min ->
#   shut down shortly after.
#
# First-time setup
#   1. sudo nixos-rebuild switch --flake .#nixos-mama
#   2. docker compose --file ~/.config/winapps/compose.yaml up -d
#      (downloads the Windows ISO and installs Windows, watch the progress at
#      http://127.0.0.1:8006, login is david / winapps)
#   3. Install and activate Office inside Windows.
#   4. winapps-setup   (adds Word/Excel/... to the app menu)
#
# Daily use
#   Just open Word from the app menu. Manual control:
#     docker compose --file ~/.config/winapps/compose.yaml start|stop|down
#   Reset everything: `down`, then delete ~/.local/share/winapps (Windows disk).
#
# Backup (do this once Office is installed and activated)
#   The VM was once reinstalled from scratch (losing Office), so keep a copy.
#     winapps-backup     shuts the VM down cleanly and copies the Windows disk
#                        to ~/winapps-backup (sparse, ~12G; replaces the old copy).
#                        Close Word first, shutting down closes open documents.
#   Restore:
#     docker compose --file ~/.config/winapps/compose.yaml down
#     rm -rf ~/.local/share/winapps && cp -a --sparse=always ~/winapps-backup ~/.local/share/winapps
#     docker compose --file ~/.config/winapps/compose.yaml up --no-start
#   The backup lives outside this repo; *.img is also in .gitignore as a safety net.
#
# Notes
#   - The Windows disk lives in ~/.local/share/winapps (100G, grows as used).
#   - Ports 8006 (web viewer) and 3389 (RDP) are bound to localhost only, so the
#     simple password below is not reachable from the network. If you change it,
#     change it in compose.yaml *and* winapps.conf (both below).
#   - Change RAM/cores via RAM_SIZE / CPU_CORES, then `docker compose ... up -d`.
{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  home = "/home/david";
  composeFile = "${home}/.config/winapps/compose.yaml";
  vmUser = "david";
  vmPassword = "winapps";
  # Seconds of no open Office window before WinApps pauses the VM.
  autopauseSeconds = 300;
in
{
  environment.systemPackages = [
    inputs.winapps.packages.${system}.winapps
    inputs.winapps.packages.${system}.winapps-launcher
    pkgs.freerdp
    (pkgs.writeShellScriptBin "winapps-backup" ''
      set -euo pipefail
      src="$HOME/.local/share/winapps"
      dst="$HOME/winapps-backup"
      echo "Shutting down the WinApps VM (can take up to 2 minutes)..."
      ${pkgs.docker}/bin/docker compose --file "${composeFile}" stop
      echo "Copying the Windows disk to $dst ..."
      rm -rf "$dst.new"
      mkdir -p "$dst.new"
      ${pkgs.coreutils}/bin/cp -a --sparse=always "$src"/. "$dst.new"/
      rm -rf "$dst"
      mv "$dst.new" "$dst"
      echo "Done: $dst"
    '')
  ];

  # docker itself is enabled in common.nix; david is in the docker and kvm groups.

  systemd.tmpfiles.rules = [ "d ${home}/.local/share/winapps 0755 david users -" ];

  home-manager.users.david = {
    xdg.configFile."winapps/winapps.conf".text = ''
      RDP_USER="${vmUser}"
      RDP_PASS="${vmPassword}"
      RDP_IP="127.0.0.1"
      WAFLAVOR="docker"
      RDP_SCALE=100
      AUTOPAUSE="on"
      AUTOPAUSE_TIME="${toString autopauseSeconds}"
    '';

    # Compose project that WinApps drives (JSON is valid YAML).
    xdg.configFile."winapps/compose.yaml".text = builtins.toJSON {
      name = "winapps";
      services.windows = {
        image = "ghcr.io/dockur/windows:latest";
        container_name = "WinApps";
        environment = {
          VERSION = "11";
          RAM_SIZE = "8G";
          CPU_CORES = "6";
          DISK_SIZE = "100G";
          USERNAME = vmUser;
          PASSWORD = vmPassword;
          HOME = home;
        };
        ports = [
          "127.0.0.1:8006:8006" # web viewer
          "127.0.0.1:3389:3389/tcp" # RDP
          "127.0.0.1:3389:3389/udp"
        ];
        cap_add = [
          "NET_ADMIN"
          "NET_RAW"
        ];
        stop_grace_period = "120s"; # time for Windows to shut down cleanly
        restart = "no"; # never start by itself; WinApps starts it on demand
        volumes = [
          "${home}/.local/share/winapps:/storage" # Windows C: drive
          "${home}:/shared" # Linux home as \\host.lan\Data
          "${inputs.winapps}/oem:/oem" # RemoteApp registry tweaks
        ];
        devices = [
          "/dev/kvm"
          "/dev/net/tun"
        ];
      };
    };

    # Shut Windows down when WinApps has left it paused, to free its RAM.
    systemd.user.services.winapps-autostop = {
      Unit.Description = "Shut down the WinApps VM when it is paused";
      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "winapps-autostop" ''
          state=$(${pkgs.docker}/bin/docker inspect --format '{{.State.Status}}' WinApps 2>/dev/null)
          if [ "$state" = "paused" ]; then
            ${pkgs.docker}/bin/docker unpause WinApps
            ${pkgs.docker}/bin/docker stop WinApps
          fi
        '';
      };
    };
    systemd.user.timers.winapps-autostop = {
      Unit.Description = "Check whether the WinApps VM can be shut down";
      Timer = {
        OnBootSec = "5min";
        OnUnitActiveSec = "2min";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
