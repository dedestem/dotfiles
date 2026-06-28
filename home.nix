{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./dconf.nix
    ./calendar.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.username = "david";
  home.homeDirectory = "/home/david";
  home.stateVersion = "26.05";

  # Force set .face as profile picture
  home.file.".face".source = ./assets/profilePicture.png;

  home.packages = with pkgs; [
    yaru-theme
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
    gnomeExtensions.appindicator
    gnomeExtensions.hide-system-icons
    gnomeExtensions.tiling-assistant
    gnomeExtensions.coverflow-alt-tab
    gnomeExtensions.power-off-options
    gnomeExtensions.simple-timer
    gnomeExtensions.tailscale-qs
    ptyxis
    jetbrains-mono
    nixfmt
    nixd
    bitwarden-desktop
  ];

  # --- Hide specific apps from the app grid ---
  xdg.desktopEntries = {
    "micro" = {
      name = "Micro";
      exec = "micro";
      noDisplay = true;
    };
    "cups" = {
      name = "Manage Printing";
      exec = "xdg-open http://localhost:631/";
      noDisplay = true;
    };
    "org.gnome.clocks" = {
      name = "Clocks";
      exec = "gnome-clocks";
      noDisplay = true;
    };
  };

  programs.vscode = {
    enable = true;

    profiles.default = {
      extensions =
        (with pkgs.vscode-extensions; [
          jnoortheen.nix-ide
          christian-kohler.path-intellisense
          
          # Guaranteed standard Nixpkgs attributes
          esbenp.prettier-vscode
          aaron-bond.better-comments
        ])
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "vscode-gnome-theme";
            publisher = "rafaelmardojai";
            version = "0.4.1";
            sha256 = "sha256-J4WEa6VVPks6rhzjE5oD88RwqaRjTjn/gPeZKaCS6RM=";
          }
          {
            name = "vs-code-extension";
            publisher = "inlang";
            version = "1.14.0";
            sha256 = "sha256-/tz1E8YDrJmvRbcB6CZEfl8IwUkvD+WijzfgSFPgG+0=";
          }
          {
            name = "svg-preview";
            publisher = "SimonSiefke";
            version = "2.8.2";
            sha256 = "sha256-RNUC1/NAy/kuTjVaCvpZC4OFH1d0GLzGckNbuhbOn/I=";
          }
          {
            name = "svelte-autoimport";
            publisher = "pivaszbs";
            version = "1.0.4";
            sha256 = "sha256-MqxZYKxmbuXKQkgSZFhPVts1h6l7/sxYo/cqMirRKpE=";
          }
          {
            name = "playwright";
            publisher = "ms-playwright";
            version = "1.1.9";
            sha256 = "sha256-LUVRB6+bXs4r17v8Wjq+fSs++PiZPnebso70BcO3o7w=";
          }
          {
            name = "pretty-ts-errors";
            publisher = "YoavBls";
            version = "0.5.4";
            sha256 = "sha256-SMEqbpKYNck23zgULsdnsw4PS20XMPUpJ5kYh1fpd14=";
          }
          {
            name = "svelte-vscode";
            publisher = "svelte";
            version = "108.4.1";
            sha256 = "sha256-6MV3aW5PVl8SbF2y0cLt6ZKRba6Rb1m3Qs1fG1x63Pk=";
          }
        ];

      userSettings = {
        "workbench.colorTheme" = "GNOME dark";

        "editor.minimap.enabled" = false;
        "workbench.sideBar.location" = "right";
        "editor.autoIndentOnPaste" = true;
        "chat.disableAIFeatures" = true;
        "files.eol" = "\n";
        "workbench.startupEditor" = "readme";
        "update.mode" = "none";
        "update.showReleaseNotes" = false;
        "telemetry.telemetryLevel" = "off";
        "workbench.enableExperiments" = false;
        "git.enableSmartCommit" = true;

        "git.autofetch" = true;
        "git.confirmSync" = false;
        # Font Config
        "editor.fontFamily" = "JetBrains Mono, Droid Sans Mono, monospace";
        "editor.fontLigatures" = true;
        "editor.fontSize" = 17;

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";

        "nix.hiddenLanguageServerErrors" = [
          "formatting"
          "errors"
        ];
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
          "editor.formatOnSave" = true;
        };
      };
    };
  };

  # Secrets - Handled natively via sops-nix
  sops = {
    age.keyFile = "/home/david/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    secrets."id_server1_ubuntu_ssh" = {
      path = "${config.home.homeDirectory}/.ssh/id_server1_ubuntu_ssh";
      mode = "0600";
    };
    secrets."id_github" = {
      path = "${config.home.homeDirectory}/.ssh/id_github";
      mode = "0600";
    };
  };

  # Plaintext public key registration
  home.file.".ssh/id_server1_ubuntu_ssh.pub".text =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINC2BjkSOojrRJMWFFnQc4BWPtsap8K7Uz8PT1LYbC5u david@server1-ubuntu-ssh";

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "ssh.davidnet.net 192.168.1.141 server1" = {
        identityFile = "~/.ssh/id_server1_ubuntu_ssh";
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      eval "$(direnv hook zsh)"
      export DIRENV_WARN_TIMEOUT=0
    '';

    shellAliases = {
      ll = "ls -l";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "david@davidnet.net";
        name = "dedestem";
      };
      init.defaultBranch = "main";
      core.sshCommand = "ssh -i ~/.ssh/id_github";
      merge.conflictstyle = "zdiff3";
      diff.algorithm = "histogram";
      diff.colorMoved = "default";
      core.whitespace = "fix,space-before-tab,trailing-space";
      pull.rebase = true;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  gtk = {
    enable = true;
    gtk3.bookmarks = [
      "onedrive://david.bos@outlook.com/ OneDrive"

      "file:///home/david/Documents Documents"
      "file:///home/david/Music Music"
      "file:///home/david/Pictures Pictures"
      "file:///home/david/Videos Videos"
      "file:///home/david/Downloads Downloads"
    ];
  };

  programs.home-manager.enable = true;
}
