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
    "slack"
  ];

  # OpenAI Codex CLI from codex-nix flake
  home.packages = with pkgs; [
    # Stable packages
    ripgrep # file search
    nil # nix language lsp
    nixpkgs-fmt
    gcc
    nodejs
    neovim # code editor
    unzip # stylua
    cargo # rust
    rustc
    python312

    # Desktop
    wofi # Wayland rofi replacement
    wl-clipboard # Wayland clipboard
    waybar # Status bar for Hyprland
    mako # Notification daemon for Wayland
    libnotify # notify-send command
    swww # Wallpaper
    adwaita-icon-theme # Icon theme for system icons (fixes fcitx tray icon)

    # Bluetooth management
    bluez-tools # Command line tools
    pavucontrol # Audio control GUI

    discord
    steam
  ] ++ (with unstablePkgs; [
    # Unstable packages - 최신 버전이 필요한 패키지들
    claude-code
    opencode
    codex
    amp-cli
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
    source = ./config/wallpapers;
    recursive = true;
  };
}
  
