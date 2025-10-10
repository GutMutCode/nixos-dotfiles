{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      # Language servers
      lua-language-server
      nil # Nix LSP

      # Formatters
      stylua
      nixpkgs-fmt

      # Additional tools
      ripgrep
      fd
      git
    ];

    plugins = with pkgs.vimPlugins; [
      # Plugin manager
      lazy-nvim

      # LazyVim
      LazyVim

      # UI
      bufferline-nvim
      lualine-nvim
      which-key-nvim
      noice-nvim
      nui-nvim
      nvim-notify

      # Snacks
      snacks-nvim

      # LSP
      nvim-lspconfig
      conform-nvim
      nvim-lint
      lazydev-nvim

      # Treesitter
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      log-highlight-nvim

      # Coding
      ts-comments-nvim
      octo-nvim
      diffview-nvim
      mini-nvim
      inc-rename-nvim
      treesj
      peek-nvim

      # AI
      sidekick-nvim

      # Telescope
      telescope-nvim
      plenary-nvim

      # Colorschemes
      tokyonight-nvim
      rose-pine
      catppuccin-nvim

      # Dependencies
      nvim-web-devicons
    ];

    extraLuaConfig = ''
      -- Bootstrap configuration
      if vim.env.VSCODE then
        vim.g.vscode = true
      end

      if vim.loader then
        vim.loader.enable()
      end

      _G.dd = function(...)
        require("snacks.debug").inspect(...)
      end
      _G.bt = function(...)
        require("snacks.debug").backtrace()
      end
      _G.p = function(...)
        require("snacks.debug").profile(...)
      end
      vim._print = function(_, ...)
        dd(...)
      end

      -- Load custom config
      pcall(require, "config.env")

      -- Setup lazy.nvim with LazyVim
      require("lazy").setup({
        spec = {
          {
            "LazyVim/LazyVim",
            import = "lazyvim.plugins",
            opts = {
              news = {
                lazyvim = true,
                neovim = true,
              },
            },
          },
          { import = "plugins" },
        },
        defaults = { lazy = true },
        install = { colorscheme = { "tokyonight", "habamax" } },
        checker = {
          enabled = true,
          notify = false,
        },
        performance = {
          cache = {
            enabled = true,
          },
          rtp = {
            disabled_plugins = {
              "gzip",
              "rplugin",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
            },
          },
        },
        debug = false,
      })

      -- VeryLazy autocmd
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          require("util").version()
        end,
      })
    '';
  };

  # Symlink custom configuration files
  xdg.configFile."nvim/lua" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/nvim/lua";
    recursive = true;
  };
}
