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
  };
}
