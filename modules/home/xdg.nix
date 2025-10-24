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
    mako = "mako";
  };
in
{
  xdg.configFile = (builtins.mapAttrs
    (name: subpath: {
      source = create_symlink "${dotfiles}/${subpath}";
      recursive = true;
    })
    configs) // {
    # Default applications for file types (mimeapps.list)
    "mimeapps.list" = {
      source = create_symlink "${dotfiles}/mimeapps.list";
    };
  };

  home.file."Pictures/wallpapers" = {
    source = create_symlink "${dotfiles}/wallpapers";
    recursive = true;
  };
}
