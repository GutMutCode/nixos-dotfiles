{ pkgs, unstablePkgs, ... }:

{
  home.packages = with pkgs; [
    # Editor
    neovim

    # LSP servers
    nil
    lua-language-server
    nodePackages.bash-language-server
    pyright
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    nodePackages.yaml-language-server
    zls

    # Formatters
    nixpkgs-fmt
    stylua
    nodePackages.prettier
    shfmt

    # Linters
    shellcheck
    nodePackages.eslint_d
    ruff

    # Development tools
    gcc
    nodejs
    deno
    cargo
    rustc
    python312
    git
    gh

    # CLI utilities
    ripgrep
    fd
    jq
    bc
    unzip

    # Security
    sops
    age
    ssh-to-age

    # Wayland/Hyprland
    rofi-wayland
    wl-clipboard
    waybar
    libnotify
    swww
    hyprpicker
    grim
    slurp
    satty
    cliphist
    wallust
    imv

    # Image processing
    imagemagick
    tesseract

    # System utilities
    adwaita-icon-theme
    bluez-tools
    pavucontrol
    playerctl

    # Applications
    kdePackages.dolphin
    discord
    spotify
    (steam.override {
      extraPkgs = pkgs: with pkgs; [
        noto-fonts-cjk-sans
      ];
    })

    # Claude Code from npm (latest 2.0.22)
    claude-code-npm
    # OpenCode from npm (latest 0.15.8)
    opencode

    # OpenAI Codex from custom package (latest 0.47.0)
    openai-codex
  ] ++ (with unstablePkgs; [
    # Development (unstable)
    amp-cli
    tshark
    zig

    # Creative (unstable)
    (blender.override {
      cudaSupport = true;
    })
    davinci-resolve
    godot
    unityhub
  ]);
}
