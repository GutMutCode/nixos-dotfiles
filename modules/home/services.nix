{ pkgs, ... }:

let
  # Helper function to create Wayland graphical session service
  # Reduces boilerplate for systemd.user.services
  mkGraphicalService = description: execStart: {
    Unit = {
      Description = description;
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = execStart;
      Restart = "on-failure";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
in
{
  services = {
    "ssh-agent" = {
      enable = true;
    };

    mako.enable = true;
  };

  systemd.user.services = {
    cliphist = mkGraphicalService
      "Clipboard history daemon for Wayland"
      "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";

    swww-daemon = mkGraphicalService
      "Smooth Wayland wallpaper daemon"
      "${pkgs.swww}/bin/swww-daemon --format xrgb";
  };
}
