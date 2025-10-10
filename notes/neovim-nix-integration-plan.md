# Neovim + Nix Seamless Integration Plan

## Problem Analysis

### Current Issue
- **Error**: `E152: Cannot open /nix/store/.../doc/tags for writing`
- **Root Cause**: lazy.nvim attempts to generate help tags in read-only `/nix/store`
- **Current Architecture**: Hybrid approach using Nix for installation + lazy.nvim for configuration

### Architecture Decision Matrix

| Approach | Declarative | Performance | Lua Config | Migration Cost | Recommended |
|----------|-------------|-------------|------------|----------------|-------------|
| Quick Fix | Low | High | ✓ | Minimal | No - Band-aid |
| lazy-nix-helper | Medium | High | ✓ | Low | **Yes** |
| nixvim | High | Medium | ✗ | High | No - Too disruptive |

## Recommended Solution: lazy-nix-helper Integration

### Why This Approach?
1. **Preserves current lua configuration structure** - No rewrite needed
2. **Maintains lazy loading performance** - Best startup times
3. **Keeps Nix reproducibility** - Version pinning via flake.lock
4. **Solves /nix/store write issue** - Proper path management
5. **Cross-platform compatible** - Works on non-NixOS systems

### Implementation Plan

#### Phase 1: Setup lazy-nix-helper (Priority 1)

**1.1 Add Plugin to Nix Configuration**

File: `modules/neovim.nix`

```nix
let
  # Add lazy-nix-helper custom plugin
  lazy-nix-helper = pkgs.vimUtils.buildVimPlugin {
    pname = "lazy-nix-helper.nvim";
    version = "2.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "b-src";
      repo = "lazy-nix-helper.nvim";
      rev = "v2.1.0";
      sha256 = "sha256-HASH"; # Run nix-prefetch-git to get hash
    };
  };
in
{
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
      lazy-nix-helper  # Add this
      # ... rest of plugins
    ];
  };
}
```

**1.2 Create Plugin Path Mapping Helper**

File: `config/nvim/lua/util/nix-plugins.lua` (new)

```lua
-- nix_plugin_path_management
-- This module provides seamless integration between Nix-managed plugins and lazy.nvim

local M = {}

-- plugin_metadata_extracted_from_nix_store
M.nix_plugins = {
  ["lazy.nvim"] = "${pkgs.vimPlugins.lazy-nvim}",
  ["plenary.nvim"] = "${pkgs.vimPlugins.plenary-nvim}",
  ["nvim-web-devicons"] = "${pkgs.vimPlugins.nvim-web-devicons}",
  ["nvim-lspconfig"] = "${pkgs.vimPlugins.nvim-lspconfig}",
  ["nvim-treesitter"] = "${pkgs.vimPlugins.nvim-treesitter}",
  ["telescope.nvim"] = "${pkgs.vimPlugins.telescope-nvim}",
  ["telescope-fzf-native.nvim"] = "${pkgs.vimPlugins.telescope-fzf-native-nvim}",
  ["claudecode.nvim"] = "${claudecode-nvim}",
  ["tokyonight.nvim"] = "${pkgs.vimPlugins.tokyonight-nvim}",
  ["lualine.nvim"] = "${pkgs.vimPlugins.lualine-nvim}",
  ["bufferline.nvim"] = "${pkgs.vimPlugins.bufferline-nvim}",
  ["noice.nvim"] = "${pkgs.vimPlugins.noice-nvim}",
  ["nui.nvim"] = "${pkgs.vimPlugins.nui-nvim}",
  ["nvim-notify"] = "${pkgs.vimPlugins.nvim-notify}",
  ["treesj"] = "${pkgs.vimPlugins.treesj}",
  ["inc-rename.nvim"] = "${pkgs.vimPlugins.inc-rename-nvim}",
  ["mini.nvim"] = "${pkgs.vimPlugins.mini-nvim}",
  ["which-key.nvim"] = "${pkgs.vimPlugins.which-key-nvim}",
  ["diffview.nvim"] = "${pkgs.vimPlugins.diffview-nvim}",
  ["snacks.nvim"] = "${pkgs.vimPlugins.snacks-nvim}",
  ["lazydev.nvim"] = "${pkgs.vimPlugins.lazydev-nvim}",
}

-- initialize_lazy_nix_helper_if_on_nixos
function M.setup()
  local helper = require("lazy-nix-helper")
  helper.setup({
    input_plugin_table = M.nix_plugins,
    auto_plugin_discovery = false,
  })
end

-- get_plugin_path_from_nix_or_fallback
function M.get_path(plugin_name)
  local helper = require("lazy-nix-helper")
  return helper.get_plugin_path(plugin_name)
end

-- check_if_running_on_nixos
function M.is_nixos()
  return vim.fn.isdirectory("/nix/store") == 1
end

return M
```

#### Phase 2: Update Nix Configuration (Priority 1)

**2.1 Modify extraLuaConfig**

File: `modules/neovim.nix:87-126`

```nix
extraLuaConfig = ''
  vim.opt.runtimepath:append("${pkgs.vimPlugins.nvim-treesitter.withAllGrammars}/parser")

  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- debug_helpers_using_snacks_nvim
  pcall(function()
    _G.dd = function(...) require("snacks.debug").inspect(...) end
    _G.bt = function() require("snacks.debug").backtrace() end
    _G.p = function(...) require("snacks.debug").profile(...) end
  end)

  -- initialize_nix_plugin_path_helper
  local nix_plugins = require("util.nix-plugins")
  nix_plugins.setup()

  -- configure_lazy_nvim_for_nix_integration
  require("lazy").setup({
    spec = {
      { import = "plugins" },
    },
    performance = {
      reset_packpath = false,
      rtp = {
        reset = false,
      },
    },
    dev = {
      path = "${pkgs.vimUtils.packDir config.programs.neovim.finalPackage.passthru.packpathDirs}/pack/myNeovimPackages/start",
      patterns = { "" },
    },
    install = {
      missing = false,
    },
    change_detection = {
      enabled = false,  -- Disable since Nix manages plugin updates
    },
    pkg = {
      enabled = false,  -- Disable package management
    },
    rocks = {
      enabled = false,  -- Disable luarocks integration
    },
  })

  require("config")
'';
```

#### Phase 3: Automatic Plugin Path Generation (Priority 2)

**3.1 Create Nix Function to Generate Plugin Mapping**

File: `modules/neovim.nix:3-14` (modify let block)

```nix
let
  # custom_plugins_from_github
  claudecode-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "claudecode.nvim";
    version = "unstable-2025-01-10";
    src = pkgs.fetchFromGitHub {
      owner = "coder";
      repo = "claudecode.nvim";
      rev = "ac2baef386d8078ef2a0aaa98580d25ec178f40a";
      sha256 = "sha256-RnMcLYjffkK4ImJ1eKrVzNRUQKD9uo0o84Tf+/LxFbM=";
    };
  };

  lazy-nix-helper = pkgs.vimUtils.buildVimPlugin {
    pname = "lazy-nix-helper.nvim";
    version = "2.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "b-src";
      repo = "lazy-nix-helper.nvim";
      rev = "v2.1.0";
      sha256 = ""; # TODO: Get actual hash
    };
  };

  # generate_plugin_path_mapping_for_lua
  pluginPathMapping = plugins: lib.strings.concatMapStringsSep "\n" (plugin:
    let
      pluginName = plugin.pname or (builtins.parseDrvName plugin.name).name;
    in
    ''["${pluginName}"] = "${plugin}",''
  ) plugins;

  allPlugins = with pkgs.vimPlugins; [
    lazy-nvim
    lazy-nix-helper
    plenary-nvim
    nvim-web-devicons
    nvim-lspconfig
    (nvim-treesitter.withPlugins (p: [
      p.lua p.nix p.bash p.python p.javascript p.typescript p.rust p.markdown
    ]))
    telescope-nvim
    telescope-fzf-native-nvim
    claudecode-nvim
    tokyonight-nvim
    lualine-nvim
    bufferline-nvim
    noice-nvim
    nui-nvim
    nvim-notify
    treesj
    inc-rename-nvim
    mini-nvim
    which-key-nvim
    diffview-nvim
    snacks-nvim
    lazydev-nvim
  ];

  # inject_plugin_paths_into_lua_configuration
  pluginPathsLua = ''
    return {
      ${pluginPathMapping allPlugins}
    }
  '';
in
```

**3.2 Write Plugin Paths to Lua File**

File: `modules/neovim.nix` (add to config section)

```nix
# write_nix_plugin_paths_to_lua_config
xdg.configFile."nvim/lua/util/nix-plugins.lua".text = ''
  local M = {}
  M.nix_plugins = ${pluginPathsLua}
  function M.setup()
    if vim.fn.isdirectory("/nix/store") == 1 then
      require("lazy-nix-helper").setup({
        input_plugin_table = M.nix_plugins,
      })
    end
  end
  function M.get_path(name)
    return require("lazy-nix-helper").get_plugin_path(name)
  end
  return M
'';
```

#### Phase 4: Update Individual Plugin Configs (Priority 3)

**4.1 Add dir Property to Plugin Specs**

Example for `config/nvim/lua/plugins/telescope.lua`:

```lua
return {
  {
    "nvim-telescope/telescope.nvim",
    dir = require("util.nix-plugins").get_path("telescope.nvim"),
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    },
    dependencies = {
      { "nvim-lua/plenary.nvim", dir = require("util.nix-plugins").get_path("plenary.nvim") },
      { "nvim-telescope/telescope-fzf-native.nvim", dir = require("util.nix-plugins").get_path("telescope-fzf-native.nvim") },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-u>"] = false,
            ["<C-d>"] = false,
          },
        },
      },
    },
  },
}
```

**Files to Update:**
- [x] `config/nvim/lua/plugins/telescope.lua`
- [ ] `config/nvim/lua/plugins/bufferline.lua`
- [ ] `config/nvim/lua/plugins/lualine.lua`
- [ ] `config/nvim/lua/plugins/noice.lua`
- [ ] `config/nvim/lua/plugins/lsp.lua`
- [ ] `config/nvim/lua/plugins/treesitter.lua`
- [ ] `config/nvim/lua/plugins/diffview.lua`
- [ ] `config/nvim/lua/plugins/treesj.lua`
- [ ] `config/nvim/lua/plugins/mini.lua`
- [ ] `config/nvim/lua/plugins/which-key.lua`
- [ ] `config/nvim/lua/plugins/snacks.lua`
- [ ] `config/nvim/lua/plugins/lazydev.lua`
- [ ] `config/nvim/lua/plugins/inc-rename.lua`
- [ ] `config/nvim/lua/plugins/claudecode.lua`

#### Phase 5: Testing & Validation (Priority 4)

**5.1 Test Checklist**

```bash
# verify_nix_build
nix flake check
nix build .#nixosConfigurations.nixos-gmc.config.system.build.toplevel

# apply_configuration
sudo nixos-rebuild switch --flake .#nixos-gmc

# test_neovim_startup
nvim --headless "+Lazy check" +qa
nvim --startuptime startup.log +qa && cat startup.log

# verify_no_errors
nvim +checkhealth
```

**5.2 Expected Outcomes**
- ✓ No `E152: Cannot open ... for writing` errors
- ✓ All plugins load correctly
- ✓ Help tags available via `:help`
- ✓ Lazy loading works (check with `:Lazy profile`)
- ✓ Startup time < 50ms

#### Phase 6: Optimization (Priority 5)

**6.1 Optional: Create Helper Script**

File: `scripts/update-neovim-plugins.sh`

```bash
#!/usr/bin/env bash
# update_neovim_plugin_versions_and_rebuild

set -e

echo "Updating flake inputs..."
nix flake update

echo "Building new configuration..."
nix build .#nixosConfigurations.nixos-gmc.config.system.build.toplevel

echo "Testing Neovim startup..."
nvim --headless "+Lazy check" +qa

echo "✓ Plugin update complete. Run 'sudo nixos-rebuild switch --flake .#nixos-gmc' to apply."
```

**6.2 Document Common Operations**

Add to `CLAUDE.md`:

```markdown
### Neovim Plugin Management
- **Check plugin status**: `nvim +Lazy`
- **Update plugins**: `nix flake update && sudo nixos-rebuild switch --flake .#nixos-gmc`
- **Add new plugin**:
  1. Add to `modules/neovim.nix` plugins list
  2. Create config in `config/nvim/lua/plugins/<name>.lua`
  3. Rebuild system
- **Profile startup**: `nvim --startuptime startup.log +qa && cat startup.log`
```

## Implementation Timeline

### Immediate (Day 1)
1. Add lazy-nix-helper to flake
2. Update lazy.nvim configuration
3. Test basic functionality

### Short-term (Week 1)
4. Update all plugin configs with dir properties
5. Complete testing checklist
6. Document changes

### Optional Enhancements
- Automated plugin path generation
- Cross-platform testing
- Performance profiling automation

## Rollback Plan

If issues occur:

```bash
# revert_to_previous_generation
sudo nixos-rebuild switch --rollback

# or_use_git
git stash
sudo nixos-rebuild switch --flake .#nixos-gmc
```

Keep this plan file for reference: `notes/neovim-nix-integration-plan.md`

## Success Metrics

- [ ] Zero help tags errors
- [ ] All 14 plugins load without warnings
- [ ] Startup time maintained or improved
- [ ] Help documentation accessible
- [ ] Configuration remains declarative and reproducible

## References

- [lazy-nix-helper GitHub](https://github.com/b-src/lazy-nix-helper.nvim)
- [Nix + lazy.nvim Guide](https://breuer.dev/blog/nix-lazy-neovim)
- [NixOS Wiki - Neovim](https://nixos.wiki/wiki/Neovim)
