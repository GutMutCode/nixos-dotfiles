{ pkgs, unstablePkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    ripgrep
    fd
    nil
    nixpkgs-fmt
    gcc
    nodejs
    unzip
    cargo
    rustc
    python312
    jq
    bc
    sops
    age
    ssh-to-age
    gh
    rofi-wayland
    wl-clipboard
    waybar
    libnotify
    swww
    hyprpicker
    grim
    slurp
    satty
    imagemagick
    tesseract
    cliphist
    wallust
    adwaita-icon-theme
    bluez-tools
    pavucontrol
    playerctl
    kdePackages.dolphin
    discord
    spotify
    (steam.override {
      extraPkgs = pkgs: with pkgs; [
        noto-fonts-cjk-sans
      ];
    })
  ] ++ (with unstablePkgs; [
    claude-code
    opencode
    codex
    amp-cli
    (blender.override {
      cudaSupport = true;
    })
    davinci-resolve
    godot
    tshark
  ]);
}
