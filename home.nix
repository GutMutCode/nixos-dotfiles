{ config, pkgs, lib, unstablePkgs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    hypr = "hypr"; # Hyprland configuration
    waybar = "waybar"; # Status bar
    fcitx5 = "fcitx5"; # i18n Multilingure
    wallust = "wallust"; # Theme generator
    rofi = "rofi"; # Application launcher
    nvim = "nvim"; # Neovim configuration
  };
  secretsDir = ./secrets;
  homeSecretsCandidate = "${secretsDir}/home.yaml";
  homeSecretsPath =
    if builtins.pathExists homeSecretsCandidate then
      builtins.path { path = homeSecretsCandidate; }
    else
      null;
in

{
  # Use a predicate to allow specific unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg:
    let
      name = lib.getName pkg;
      # List of explicitly allowed packages
      allowedPackages = [
        "discord"
        "spotify"
        "steam"
        "steam-unwrapped"
        "slack"
        "blender"
        "factory-cli"
      ];
      # Allow all CUDA packages (cuda_*, libcu*, libnv*, etc.)
      isCudaPackage = builtins.match "^(cuda_.*|libcu.*|libnv.*)" name != null;
    in
    builtins.elem name allowedPackages || isCudaPackage;

  # OpenAI Codex CLI from codex-nix flake
  home.packages = with pkgs; [
    # Editor
    neovim # Text editor (plugins and LSPs managed by lazy.nvim and mason.nvim in ~/.config/nvim)

    # Development Tools
    ripgrep # Fast file content search (used by Telescope)
    fd # Fast file finder (used by Telescope)
    nil # Nix language server
    nixpkgs-fmt # Nix code formatter
    gcc # C/C++ compiler
    nodejs # JavaScript runtime
    unzip # Archive extraction
    cargo # Rust package manager
    rustc # Rust compiler
    python312 # Python interpreter
    jq # JSON processor for scripts
    bc # Calculator for shell scripts
    sops # Secret editing tool
    age # Age key management
    ssh-to-age # Convert SSH keys to age recipients
    gh # github
    factory-cli # Custom CLI tool from local overlay

    # Hyprland Core Utilities
    rofi-wayland # Application launcher for Wayland
    wl-clipboard # Wayland clipboard utilities (wl-copy, wl-paste)
    waybar # Status bar for Hyprland
    libnotify # notify-send command for notifications
    swww # Smooth wallpaper daemon with transitions
    hyprpicker # Color picker for Hyprland

    # Screenshot & Image Tools
    grim # Screenshot utility for Wayland
    slurp # Screen area selection tool
    satty # Screenshot annotation tool (alternative: swappy)
    imagemagick # Image processing for OCR preprocessing
    tesseract # OCR text recognition engine

    # Clipboard Management
    cliphist # Clipboard history manager for Wayland

    # Theming & Visual
    wallust # Color scheme generator from wallpapers
    adwaita-icon-theme # GTK icon theme (fixes system tray icons)

    # Audio & Bluetooth
    bluez-tools # Bluetooth command line tools
    pavucontrol # PulseAudio volume control GUI
    playerctl # Media player controller (MPRIS)

    # File Management
    kdePackages.dolphin # KDE file manager (Qt 6)

    # Applications
    discord # Communication platform
    (steam.override {
      extraPkgs = pkgs: with pkgs; [
        noto-fonts-cjk-sans
      ];
    }) # Gaming platform with Korean font support
    spotify
    (blender.override {
      cudaSupport = true; # NVIDIA CUDA/OptiX support for Cycles rendering
    }) # 3D creation suite with GPU acceleration
  ] ++ (with unstablePkgs; [
    # Unstable packages - 최신 버전이 필요한 패키지들
    claude-code # AI coding assistant
    opencode # Code editor
    codex # AI CLI tool
    amp-cli # Amplify CLI
    # tor - managed by system service (configuration.nix services.tor)
  ]);

  home = {
    username = "gmc";
    homeDirectory = "/home/gmc";
    stateVersion = "25.05";
    sessionVariables = {
      GTK_IM_MODULE = "";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      GLFW_IM_MODULE = "ibus"; # For some applications that need ibus fallback
    };
    # Cursor theme configuration
    pointerCursor =
      let
        getFrom = url: hash: name: {
          gtk.enable = true;
          x11.enable = true;
          name = name;
          size = 24;
          package = pkgs.runCommand "moveUp" { } ''
            mkdir -p $out/share/icons
            ln -s ${pkgs.fetchzip {
              url = url;
              hash = hash;
            }} $out/share/icons/${name}
          '';
        };
      in
      getFrom
        "https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Ice.tar.xz"
        "sha256-SG/NQd3K9DHNr9o4m49LJH+UC/a1eROUjrAQDSn3TAU="
        "Bibata-Modern-Ice";
  };

  programs = {
    git = {
      enable = true;
      userName = "gutmutcode";
      userEmail = "gutmutcode@gmail.com";
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
      };
    };

    ssh = {
      enable = true;
      addKeysToAgent = "confirm";
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = [ "${config.home.homeDirectory}/.ssh/id_ed25519_github" ];
          identitiesOnly = true;
        };
      };
    };

    bash = {
      enable = true;
      shellAliases = {
        btw = "echo I use nixos btw";
        firefox-tor = "firefox -P tor";
      };
    };

    alacritty = {
      enable = true;
      settings = {
        font = {
          normal = {
            family = "JetBrains Mono Nerd Font";
            style = "Regular";
          };
          size = 16;
        };
        window = {
          padding = {
            x = 12;
            y = 4;
          };
          decorations = "Full";
        };
        scrolling = {
          history = 10000;
          multiplier = 3;
        };
        general = {
          live_config_reload = true;
          import = [ "~/.config/alacritty/colors-wallust.toml" ];
        };
      };
    };

    obs-studio = {
      enable = true;
      package = (pkgs.obs-studio.override {
        cudaSupport = true; # NVIDIA CUDA support for NVENC hardware encoding
      });
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs # Wayland screen capture
        obs-pipewire-audio-capture # PipeWire audio integration
        obs-vkcapture # Vulkan game capture
        obs-backgroundremoval # AI background removal
      ];
    };

    firefox = {
      enable = true;
      profiles = {
        default = {
          id = 0;
          name = "default";
          isDefault = true;
        };

        tor = {
          id = 1;
          name = "tor";
          settings = {
            # Tor SOCKS5 프록시 설정
            "network.proxy.type" = 1;
            "network.proxy.socks" = "127.0.0.1";
            "network.proxy.socks_port" = 9050;
            "network.proxy.socks_version" = 5;
            "network.proxy.socks_remote_dns" = true;

            # 프라이버시 강화 설정
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;
            "privacy.firstparty.isolate" = true;
            "network.cookie.cookieBehavior" = 1;
            "network.dns.disablePrefetch" = true;
            "network.prefetch-next" = false;
            "webgl.disabled" = true;
            "geo.enabled" = false;
          };
        };
      };
    };
  };

  services = {
    "ssh-agent" = {
      enable = true;
    };

    mako = {
      enable = true;
      # All settings use the new `settings` attribute
      settings = {
        # Wallust dynamic colors included via xdg.configFile symlink
        layer = "overlay";
        font = "JetBrains Mono Nerd Font 13";
        anchor = "top-right";
        margin = "16,16,0,0";
        default-timeout = 5000;
        ignore-timeout = 0;
        width = 380;
        height = 120;
        padding = "12,16";
        border-size = 1;
        border-radius = 10;
        icons = 1;
        icon-path = "/usr/share/icons/Papirus-Dark";
        max-icon-size = 48;
        markup = 1;
        actions = 1;
        group-by = "app-name";
      };
    };
  };

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs // {
    # Wallust will write directly to ~/.config/alacritty/colors-wallust.toml
    # and ~/.config/mako/colors-wallust - no symlink needed
  };

  home.file."Pictures/wallpapers" = {
    source = create_symlink "${dotfiles}/wallpapers";
    recursive = true;
  };

  sops =
    {
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    }
    // lib.optionalAttrs (homeSecretsPath != null) {
      defaultSopsFile = homeSecretsPath;
      secrets.git-ssh-key = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519_github";
        mode = "0600";
      };
    };

  # Systemd user services for Hyprland
  systemd.user.services = {
    # Clipboard history daemon
    cliphist = {
      Unit = {
        Description = "Clipboard history daemon for Wayland";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # Wallpaper daemon (swww)
    swww-daemon = {
      Unit = {
        Description = "Smooth Wayland wallpaper daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.swww}/bin/swww-daemon --format xrgb";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
  
