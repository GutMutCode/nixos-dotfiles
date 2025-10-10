# Neovim Enhancement Plan

Based on analysis of repos/dot/nvim configuration.

## Phase 1: Immediate Improvements (Low Complexity)

### Task 1.1: Add Keymaps
**File**: `config/nvim/lua/config/init.lua`
**Action**: Add at end of file
```lua
-- Window navigation with arrow keys
vim.keymap.set("n", "<Up>", "<c-w>k")
vim.keymap.set("n", "<Down>", "<c-w>j")
vim.keymap.set("n", "<Left>", "<c-w>h")
vim.keymap.set("n", "<Right>", "<c-w>l")
```
**Benefit**: More intuitive window navigation

### Task 1.2: Improve Options
**File**: `config/nvim/lua/config/init.lua`
**Action**: Add after line 34 (after `opt.undofile = true`)
```lua
-- Backup configuration
opt.backup = true
opt.backupdir = vim.fn.stdpath("state") .. "/backup"

-- UI improvements
opt.cmdheight = 0
opt.mousescroll = "ver:1,hor:4"
```
**Benefit**: Better backup system, cleaner UI

### Task 1.3: Create Keymaps Module
**File**: `config/nvim/lua/config/keymaps.lua` (NEW)
**Action**: Create new file
```lua
-- Make all keymaps silent by default
local keymap_set = vim.keymap.set
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  return keymap_set(mode, lhs, rhs, opts)
end

-- Window navigation
vim.keymap.set("n", "<Up>", "<c-w>k")
vim.keymap.set("n", "<Down>", "<c-w>j")
vim.keymap.set("n", "<Left>", "<c-w>h")
vim.keymap.set("n", "<Right>", "<c-w>l")
```
**Benefit**: Centralized keymap management

### Task 1.4: Load Keymaps Module
**File**: `config/nvim/lua/config/init.lua`
**Action**: Add at end of file
```lua
-- Load keymaps
require("config.keymaps")
```

### Task 1.5: Create Autocmds Module
**File**: `config/nvim/lua/config/autocmds.lua` (NEW)
**Action**: Create new file
```lua
-- Show cursor line only in active window
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
  callback = function()
    if vim.w.auto_cursorline then
      vim.wo.cursorline = true
      vim.w.auto_cursorline = nil
    end
  end,
})

vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
  callback = function()
    if vim.wo.cursorline then
      vim.w.auto_cursorline = true
      vim.wo.cursorline = false
    end
  end,
})

-- Better backups with path-based names
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("better_backup", { clear = true }),
  callback = function(event)
    local file = vim.uv.fs_realpath(event.match) or event.match
    local backup = vim.fn.fnamemodify(file, ":p:~:h")
    backup = backup:gsub("[/\\]", "%%")
    vim.go.backupext = backup
  end,
})
```
**Benefit**: Better visual feedback and backup management

### Task 1.6: Load Autocmds Module
**File**: `config/nvim/lua/config/init.lua`
**Action**: Add at end of file
```lua
-- Load autocmds
require("config.autocmds")
```

---

## Phase 2: Essential Plugins (Medium Complexity)

### Task 2.1: Add TreeSJ Plugin
**File**: `modules/neovim.nix`
**Action**: Add to plugins list
```nix
treesj  # Split/join code blocks
```
**File**: `config/nvim/lua/plugins/treesj.lua` (NEW)
```lua
return {
  {
    "Wansmer/treesj",
    keys = {
      { "J", "<cmd>TSJToggle<cr>", desc = "Split/Join Toggle" },
    },
    opts = {
      use_default_keymaps = false,
      max_join_length = 150,
    },
  },
}
```
**Benefit**: Quick code block split/join with J key

### Task 2.2: Add Inc-Rename Plugin
**File**: `modules/neovim.nix`
**Action**: Add to plugins list
```nix
inc-rename-nvim  # LSP rename with preview
```
**File**: `config/nvim/lua/plugins/inc-rename.lua` (NEW)
```lua
return {
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = true,
  },
}
```
**File**: `config/nvim/lua/plugins/lsp.lua`
**Action**: Update rename keymap (around line 12)
```lua
vim.keymap.set("n", "<leader>rn", ":IncRename ", opts)
```
**Benefit**: Live preview when renaming symbols

### Task 2.3: Add Mini.align Plugin
**File**: `modules/neovim.nix`
**Action**: Add to plugins list
```nix
mini-nvim  # Mini modules collection
```
**File**: `config/nvim/lua/plugins/mini.lua` (NEW)
```lua
return {
  {
    "echasnovski/mini.nvim",
    config = function()
      require("mini.align").setup()
    end,
    keys = {
      { "ga", mode = { "n", "v" }, desc = "Align" },
      { "gA", mode = { "n", "v" }, desc = "Align with preview" },
    },
  },
}
```
**Benefit**: Text alignment with ga/gA

### Task 2.4: Add Which-Key Plugin
**File**: `modules/neovim.nix`
**Action**: Add to plugins list
```nix
which-key-nvim  # Keymap guide
```
**File**: `config/nvim/lua/plugins/which-key.lua` (NEW)
```lua
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
    },
  },
}
```
**Benefit**: Visual keymap guide

### Task 2.5: Add Bufferline Plugin
**File**: `modules/neovim.nix`
**Action**: Add to plugins list
```nix
bufferline-nvim  # Buffer tabs
```
**File**: `config/nvim/lua/plugins/bufferline.lua` (NEW)
```lua
return {
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        separator_style = "slope",
        diagnostics = "nvim_lsp",
      },
    },
  },
}
```
**Benefit**: Visual buffer tabs

---

## Phase 3: Advanced Features (High Complexity)

### Task 3.1: Add Diffview Plugin
**File**: `modules/neovim.nix`
**Action**: Add to plugins list
```nix
diffview-nvim  # Git diff viewer
```
**File**: `config/nvim/lua/plugins/diffview.lua` (NEW)
```lua
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff View" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
    },
    opts = {},
  },
}
```
**Benefit**: Better git diff visualization

### Task 3.2: Add Snacks.nvim
**File**: `modules/neovim.nix`
**Action**: Add to plugins list
```nix
snacks-nvim  # Collection of useful utilities
```
**File**: `config/nvim/lua/plugins/snacks.lua` (NEW)
```lua
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      indent = { enabled = true },
      statuscolumn = { enabled = true },
    },
  },
}
```
**Benefit**: Indent guides, better statuscolumn

### Task 3.3: Add Noice.nvim (UI Overhaul)
**File**: `modules/neovim.nix`
**Action**: Add to plugins list
```nix
noice-nvim  # Better UI
nui-nvim    # UI components (dependency)
nvim-notify # Notification system (dependency)
```
**File**: `config/nvim/lua/plugins/noice.lua` (NEW)
```lua
return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
  },
}
```
**Benefit**: Modern command line, better notifications

### Task 3.4: Enhance LSP Configuration
**File**: `config/nvim/lua/plugins/lsp.lua`
**Action**: Update lua_ls settings (around line 20)
```lua
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
        disable = { "incomplete-signature-doc", "trailing-space" },
      },
      hover = { expandAlias = false },
      type = {
        castNumberToInteger = true,
        inferParamType = true,
      },
    },
  },
})
```
**Benefit**: Better Lua LSP diagnostics

---

## Phase 4: Debug Utilities (Optional)

### Task 4.1: Add Debug Helpers
**File**: `modules/neovim.nix`
**Action**: Update extraLuaConfig (before lazy setup)
```lua
-- Debug helpers (if snacks.nvim is installed)
pcall(function()
  _G.dd = function(...)
    require("snacks.debug").inspect(...)
  end
  _G.bt = function(...)
    require("snacks.debug").backtrace()
  end
end)
```
**Benefit**: Quick debugging with dd() and bt()

---

## Implementation Order

1. **Day 1**: Phase 1 (Tasks 1.1-1.6) - Foundation improvements
2. **Day 2**: Phase 2 (Tasks 2.1-2.5) - Essential plugins
3. **Day 3**: Phase 3 (Tasks 3.1-3.2) - Advanced features (except Noice)
4. **Day 4**: Phase 3 (Task 3.3-3.4) - UI overhaul
5. **Optional**: Phase 4 - Debug utilities

## Testing Checklist

After each phase:
- [ ] Run `sudo nixos-rebuild switch --flake .#nixos-gmc`
- [ ] Restart Neovim
- [ ] Test new keybindings
- [ ] Verify no errors with `:checkhealth`
- [ ] Test LSP functionality
- [ ] Test plugin features

## Rollback Plan

If issues occur:
```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or switch to specific generation
sudo nix-env --switch-generation <number> --profile /nix/var/nix/profiles/system
```

## Dependencies Summary

### Required Nix Packages
Already included in current config:
- lua-language-server
- nil
- bash-language-server
- pyright
- typescript-language-server
- stylua
- nixpkgs-fmt
- ripgrep
- fd
- git
- gcc

### Required Vim Plugins (Phase 2+)
- treesj
- inc-rename-nvim
- mini-nvim
- which-key-nvim
- bufferline-nvim
- diffview-nvim
- snacks-nvim
- noice-nvim
- nui-nvim
- nvim-notify

## Notes

- Each phase is independent and can be applied separately
- Phases build on each other but won't break if done out of order
- All changes are declarative and version controlled
- Easy rollback with NixOS generations
- Configuration can be tested with `nixos-rebuild test` before applying
