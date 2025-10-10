{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/system.nix
    ./modules/secrets.nix
    ./modules/hardware/nvidia.nix
    ./modules/hardware/bluetooth.nix
    ./modules/hardware/audio.nix
    ./modules/hardware/obs-virtual-camera.nix
    ./modules/services/ssh.nix
    ./modules/services/tor.nix
    ./modules/desktop/hyprland.nix
    ./modules/desktop/fonts.nix
    ./modules/desktop/i18n.nix
  ];
}
