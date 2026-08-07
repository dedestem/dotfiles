{ lib, ... }:

let
  # Pull in the GVariant constructors natively supported by Home Manager
  inherit (lib.hm.gvariant)
    mkTuple
    mkUint32
    mkVariant
    mkDictionaryEntry
    ;

  # Build the exact binary structures GNOME expects using Nix tuples
  amsterdam = mkVariant (mkTuple [
    (mkUint32 2)
    (mkVariant (mkTuple [
      "Amsterdam"
      "EHAM"
      true
      [
        (mkTuple [
          0.91280719879303418
          0.083194033496160544
        ])
      ]
      [
        (mkTuple [
          0.91402892926943036
          0.085346600422522706
        ])
      ]
    ]))
  ]);

  utc = mkVariant (mkTuple [
    (mkUint32 2)
    (mkVariant (mkTuple [
      "Coordinated Universal Time (UTC)"
      "@UTC"
      false
      [
        (mkTuple [
          0.0
          0.0
        ])
      ] # Dummy coordinates to bypass empty array type-checking
      [
        (mkTuple [
          0.0
          0.0
        ])
      ]
    ]))
  ]);
in
{
  dconf.settings = {
    # --- Core Desktop & Behavior ---
    "org/freedesktop/tracker/miner/files" = {
      index-recursive-directories = [ "$HOME" ];
    };

    "org/gnome/mutter" = {
      edge-tiling = false;
    };

    "org/gnome/nautilus/preferences" = {
      migrated-gtk-settings = true;
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-schedule-automatic = false;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "hibernate";
    };

    "org/gnome/software" = {
      first-run = false;
    };

    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };

    # --- Privacy & Notifications ---
    "org/gnome/desktop/privacy" = {
      disable-camera = false;
      recent-files-max-age = -1;
      remove-old-temp-files = true;
      remove-old-trash-files = true;
    };

    "org/gnome/desktop/notifications" = {
      application-children = [
        "org-gnome-console"
        "org-gnome-software"
        "gnome-power-panel"
      ];
      show-in-lock-screen = false;
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-software" = {
      application-id = "org.gnome.Software.desktop";
    };

    # --- Peripherals & Theme ---
    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/interface" = {
      clock-show-seconds = false;
      clock-show-weekday = false;
      color-scheme = "prefer-dark";
      cursor-theme = "Yaru";
      enable-hot-corners = false;
      gtk-theme = "Yaru-dark";
      icon-theme = "Yaru";
      show-battery-percentage = false;
    };

    "org/gnome/desktop/sound" = {
      event-sounds = true;
      theme-name = "__custom";
    };

    "org/gnome/desktop/background" = {
      picture-options = "zoom";
      picture-uri = "file://${./assets/wallpaper.svg}";
      picture-uri-dark = "file://${./assets/wallpaper.svg}";
    };

    "org/gnome/desktop/screensaver" = {
      picture-options = "zoom";
      picture-uri = "file://${./assets/wallpaper.svg}";
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Launch Terminal";
      command = "ptyxis";
      binding = "<Ctrl><Alt>t";
    };

    # --- Break Reminders ---
    "org/gnome/desktop/break-reminders/eyesight" = {
      play-sound = true;
    };

    "org/gnome/desktop/break-reminders/movement" = {
      duration-seconds = 300;
      interval-seconds = 1800;
      play-sound = true;
    };

    # --- Power Off Options Extension Settings ---
    "org/gnome/shell/extensions/power-off-options" = {
      show-hybrid-sleep = true;
      show-reboot-to-bios = true;
      show-settings = false;
      show-soft-reboot = true;
      show-suspend-then-hibernate = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    # --- GNOME Shell & Extensions Setup ---
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        "blur-my-shell@aunetx"
        "appindicatorsupport@rgcjonas.gmail.com"
        "hide-system-icons@shichen35.github.io"
        "CoverflowAltTab@palatis.blogspot.com"
        "power-off-options@axelitama.github.io"
        "tiling-assistant@leleat-on-github"
        "simple-timer@majortomvr.github.com"
        "tailscale-gnome-qs@tailscale-qs.github.io"
      ];
      favorite-apps = [
        "app.zen_browser.zen.desktop"
        "org.gnome.Nautilus.desktop"
        "code.desktop"
        "org.gnome.Ptyxis.desktop"
        "com.pocoguy.Muse.desktop"
      ];
    };

    "org/gnome/shell/app-switcher" = {
      current-workspace-only = false;
    };

    # --- App Indicator Extension ---
    "org/gnome/shell/extensions/appindicator" = {
      icon-brightness = 0.0;
      icon-contrast = 0.0;
      icon-opacity = 240;
      icon-saturation = 0.0;
      icon-size = 0;
    };

    # --- Blur My Shell Extension ---
    "org/gnome/shell/extensions/blur-my-shell" = {
      rounded-blur-found = false;
      settings-version = 2;
    };

    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      brightness = 0.6;
      sigma = 30;
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = true;
      brightness = 0.6;
      pipeline = "pipeline_default_rounded";
      sigma = 30;
      static-blur = true;
      style-dash-to-dock = 0;
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
      brightness = 0.6;
      corner-radius = 0;
      pipeline = "pipeline_default";
      sigma = 30;
      static-blur = false;
    };

    "org/gnome/shell/extensions/blur-my-shell/window-list" = {
      brightness = 0.6;
      sigma = 30;
    };

    # --- Text Contrast Fix for the Overview Search ---
    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      blur = true;
      brightness = 0.35;
      customize = true;
      # Dconf expects a precise tuple of 4 doubles for colors (RGBA)
      color = mkTuple [
        0.0
        0.0
        0.0
        0.4
      ];
      pipeline = "pipeline_default";
      sigma = 30;
      style-components = 1;
    };

    # --- Dash to Dock Extension ---
    "org/gnome/shell/extensions/dash-to-dock" = {
      background-opacity = 0.8;
      dash-max-icon-size = 48;
      disable-overview-on-startup = true;
      dock-position = "BOTTOM";
      height-fraction = 0.9;
      intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
      isolate-workspaces = false;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "eDP-1";
      show-apps-always-in-the-edge = true;
      show-mounts = false;
      show-show-apps-button = true;
      show-trash = false;
    };

    # --- GNOME Clocks App ---
    "org/gnome/clocks" = {
      world-clocks = [
        [
          (mkDictionaryEntry [
            "location"
            amsterdam
          ])
        ]
        [
          (mkDictionaryEntry [
            "location"
            utc
          ])
        ]
      ];
    };

    # --- GNOME Shell Dropdown Panel ---
    "org/gnome/shell/world-clocks" = {
      locations = [
        amsterdam
        utc
      ];
    };

    # --- Hide system icons extension ---
    "org/gnome/shell/extensions/hide-system-icons" = {
      hide-power-profiles = true;
      hide-bluetooth = false;
      hide-microphone = false;
      hide-network = false;
      hide-power = false;
      hide-volume = false;
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [
        "System"
        "Utilities"
        "Office"
        "Games"
      ];
    };

    # --- 1. Utilities Folder ---
    "org/gnome/desktop/app-folders/folders/Utilities" = {
      name = "Utilities";
      apps = [
        "org.gnome.baobab.desktop"
        "org.gnome.Loupe.desktop"
        "be.alexandervanhee.gradia.desktop"
      ];
    };

    # --- 2. System Folder ---
    "org/gnome/desktop/app-folders/folders/System" = {
      name = "System";
      apps = [
        "org.gnome.SystemMonitor.desktop"
        "org.gnome.Usage.desktop"
        "org.gnome.Settings.desktop"
        "org.gnome.DiskUtility.desktop"
        "org.gnome.Extension.desktop"
      ];
    };

    # --- 3. Office Folder ---
    "org/gnome/desktop/app-folders/folders/Office" = {
      name = "Office";
      apps = [
        "org.gnome.Calculator.desktop"
        "org.gnome.Characters.desktop"
        "org.gnome.Calendar.desktop"
        "org.gnome.Papers.desktop"
        "org.gnome.Contacts.desktop"
      ];
    };

    "org/gnome/desktop/app-folders/folders/Games" = {
      name = "Games";
      apps = [
        "org.vinegarhq.Sober.desktop"
        "com.modrinth.ModrinthApp.desktop"
      ];
    };

    "org/gnome/Ptyxis" = {
      default-profile-uuid = "91b8441bd490178c6bfd508a6a379738";
      profile-uuids = [ "91b8441bd490178c6bfd508a6a379738" ];

    };

    "org/gnome/Ptyxis/Profiles/91b8441bd490178c6bfd508a6a379738" = {
      label = "Main";
      palette = "gnome";

      notify-on-successor = false;
    };
  };
}
