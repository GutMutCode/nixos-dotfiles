{ config, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
    hypr = "hypr";
    waybar = "waybar";
    fcitx5 = "fcitx5";
    wallust = "wallust";
    rofi = "rofi";
    nvim = "nvim";
  };
in
{
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
}
