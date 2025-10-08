{ config, pkgs, lib, unstablePkgs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    nvim = "nvim";
    alacritty = "alacritty";
    hypr = "hypr"; # Hyprland configuration
    waybar = "waybar"; # Status bar
    fcitx5 = "fcitx5"; # i18n Multilingure
    mako = "mako"; # notify
    wallust = "wallust"; # Theme generator
    rofi = "rofi"; # Application launcher
  };
in

{
  imports =
    [
      # ./modules/neovim.nix
      # ./modules/suckless.nix
    ];

  # Use a predicate to allow specific unfree packages
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    # Add the exact package names from nixpkgs you want to allow
    "discord"
    "steam"
    "steam-unwrapped"
    "slack"
  ];

  # OpenAI Codex CLI from codex-nix flake
  home.packages = with pkgs; [
    # Development Tools
    ripgrep # Fast file content search
    nil # Nix language server
    nixpkgs-fmt # Nix code formatter
    gcc # C/C++ compiler
    nodejs # JavaScript runtime
    neovim # Terminal code editor
    unzip # Archive extraction
    cargo # Rust package manager
    rustc # Rust compiler
    python312 # Python interpreter
    jq # JSON processor for scripts
    bc # Calculator for shell scripts

    # Hyprland Core Utilities
    rofi-wayland # Application launcher for Wayland
    wl-clipboard # Wayland clipboard utilities (wl-copy, wl-paste)
    waybar # Status bar for Hyprland
    mako # Notification daemon for Wayland
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
    steam # Gaming platform
  ] ++ (with unstablePkgs; [
    # Unstable packages - 최신 버전이 필요한 패키지들
    claude-code # AI coding assistant
    opencode # Code editor
    codex # AI CLI tool
    amp-cli # Amplify CLI
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
    git.enable = true;

    bash = {
      enable = true;
      shellAliases = {
        btw = "echo I use nixos btw";
      };
    };
  };

  xdg.configFile = builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs;

  home.file."Pictures/wallpapers" = {
    source = create_symlink "${dotfiles}/wallpapers";
    recursive = true;
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
  
