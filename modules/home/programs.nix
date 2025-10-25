{ config, pkgs, ... }:

{
  programs = {
    doom-emacs = {
      enable = true;
      doomDir = ../../config/doom.d;
      doomLocalDir = "${config.home.homeDirectory}/.local/share/doom";
      emacs = pkgs.emacs-pgtk;
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };

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
      addKeysToAgent = "yes";
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = [ "${config.home.homeDirectory}/.ssh/id_ed25519_github" ];
          identitiesOnly = true;
        };
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
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

    tmux = {
      enable = true;
      terminal = "screen-256color";
      prefix = "C-s";
      mouse = true;
      keyMode = "vi";
      baseIndex = 1;
      escapeTime = 0;
      historyLimit = 10000;

      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
      ];

      extraConfig = ''
        # status-bar style
        set -g status-position top
        set -g status-style bg=default,fg=default
        set -g status-justify centre
        set-option -g status-left '#[bg=default,fg=default,bold]#{?client_prefix,,  tmux  }#[bg=#698DDA,fg=black,bold]#{?client_prefix,  tmux  ,}'
        set-option -g status-right '#S'
        set-option -g window-status-format ' #I:#W '
        set-option -g window-status-current-format '#[bg=#698DDA,fg=black] #I:#W#{?window_zoomed_flag,  , }'

        # pane style
        set -g pane-border-style fg=black
        set -g pane-active-border-style "bg=default,fg=#698DDA"

        # split window
        unbind %
        unbind '"'
        bind | split-window -h
        bind - split-window -v

        # resize window
        bind -r h resize-pane -L 5
        bind -r j resize-pane -D 5
        bind -r k resize-pane -U 5
        bind -r l resize-pane -R 5
        bind -r m resize-pane -Z

        # clear bind
        bind -r i send-keys 'C-l'
        bind b set-option -g status

        # vim copy mode
        bind-key -T copy-mode-vi 'v' send -X begin-selection
        bind-key -T copy-mode-vi 'y' send -X copy-selection
        unbind -T copy-mode-vi MouseDragEnd1Pane
      '';
    };
  };
}
