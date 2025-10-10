{ pkgs, ... }:

{
  services = {
    "ssh-agent" = {
      enable = true;
    };

    mako = {
      enable = true;
      settings = {
        layer = "overlay";
        font = "JetBrains Mono Nerd Font 13";
        anchor = "top-right";
        margin = "16,16,0,0";
        default-timeout = 5000;
        ignore-timeout = 0;
        width = 380;
        height = 120;
        padding = "12,16";
        border-size = 1;
        border-radius = 10;
        icons = 1;
        icon-path = "/usr/share/icons/Papirus-Dark";
        max-icon-size = 48;
        markup = 1;
        actions = 1;
        group-by = "app-name";
      };
    };
  };

  systemd.user.services = {
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
