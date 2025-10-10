{ config, pkgs, ... }:

{
  programs = {
    git = {
      enable = true;
      userName = "gutmutcode";
      userEmail = "gutmutcode@gmail.com";
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
      };
    };

    ssh = {
      enable = true;
      addKeysToAgent = "confirm";
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = [ "${config.home.homeDirectory}/.ssh/id_ed25519_github" ];
          identitiesOnly = true;
        };
      };
    };

    bash = {
      enable = true;
      shellAliases = {
        btw = "echo I use nixos btw";
        firefox-tor = "firefox -P tor";
      };
    };

    alacritty = {
      enable = true;
      settings = {
        font = {
          normal = {
            family = "JetBrainsMono Nerd Font";
            style = "Regular";
          };
          size = 16;
        };
        window = {
          padding = {
            x = 12;
            y = 4;
          };
          decorations = "Full";
        };
        scrolling = {
          history = 10000;
          multiplier = 3;
        };
        general = {
          live_config_reload = true;
          import = [ "~/.config/alacritty/colors-wallust.toml" ];
        };
      };
    };

    obs-studio = {
      enable = true;
      package = pkgs.obs-studio.override {
        cudaSupport = true;
      };
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
        obs-vkcapture
        obs-backgroundremoval
      ];
    };

    firefox = {
      enable = true;
      profiles = {
        default = {
          id = 0;
          name = "default";
          isDefault = true;
        };

        tor = {
          id = 1;
          name = "tor";
          settings = {
            "network.proxy.type" = 1;
            "network.proxy.socks" = "127.0.0.1";
            "network.proxy.socks_port" = 9050;
            "network.proxy.socks_version" = 5;
            "network.proxy.socks_remote_dns" = true;
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;
            "privacy.firstparty.isolate" = true;
            "network.cookie.cookieBehavior" = 1;
            "network.dns.disablePrefetch" = true;
            "network.prefetch-next" = false;
            "webgl.disabled" = true;
            "geo.enabled" = false;
          };
        };
      };
    };
  };
}
