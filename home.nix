{ config, pkgs, lib, unstablePkgs, ... }:

{
  imports = [
    ./modules/home/packages.nix
    ./modules/home/programs.nix
    ./modules/home/services.nix
    ./modules/home/xdg.nix
    ./modules/home/sops.nix
    ./modules/home/theme.nix
  ];

  # Factory AI CLI
  services.factory-cli.enable = true;

  home = {
    username = "gmc";
    homeDirectory = "/home/gmc";
    stateVersion = "25.05";
    sessionVariables = {
      GTK_IM_MODULE = "";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      GLFW_IM_MODULE = "ibus";
    };

    # Custom fonts
    file.".local/share/fonts/s-core-dream" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/nixos-dotfiles/fonts/s-core-dream";
      recursive = true;
    };
  };
}
