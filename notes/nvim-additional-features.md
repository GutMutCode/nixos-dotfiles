# Additional Neovim Features Analysis

Comparison between current config and repos/dot/nvim

## 📊 Current Status

### Already Implemented ✅
- treesj (split/join)
- inc-rename.nvim
- mini.align (mini.nvim)
- diffview.nvim
- which-key.nvim
- bufferline.nvim
- noice.nvim
- snacks.nvim
- Window navigation with arrow keys

## 🆕 New Features Found

### 1. Cowboy Mode (Anti-spam protection)
**Location**: `repos/dot/nvim/lua/util/init.lua:20-51`

**Description**: Prevents spam of hjkl+- keys by showing warning after 10 rapid presses

**Implementation**:
```lua
-- util/cowboy.lua
local M = {}

function M.setup()
  local count = {}
  for _, key in ipairs({ "h", "j", "k", "l", "+", "-" }) do
    count[key] = 0
    local timer = vim.uv.new_timer()
    vim.keymap.set("n", key, function()
      if vim.v.count > 0 then
        count[key] = 0
      end
      if count[key] >= 10 and vim.bo.buftype ~= "nofile" then
        vim.notify("Hold it Cowboy!", vim.log.levels.WARN, {
          icon = "🤠",
          id = "cowboy",
        })
      else
        count[key] = count[key] + 1
        timer:start(2000, 0, function()
          count[key] = 0
        end)
        return key
      end
    end, { expr = true, silent = true })
  end
end

return M
```

**Benefits**:
- Encourages using counts (5j instead of jjjjj)
- Improves Vim skills
- Fun notification

**Recommendation**: ⭐⭐⭐ Worth implementing (educational)

---

### 2. ts-comments.nvim
**Location**: `repos/dot/nvim/lua/plugins/coding.lua:3-9`

**Description**: Better comment strings for different languages

**Already Handled**: Treesitter handles this, likely not needed

**Recommendation**: ⭐ Skip (redundant)

---

### 3. octo.nvim
**Location**: `repos/dot/nvim/lua/plugins/coding.lua:10-15`

**Description**: GitHub integration (issues, PRs) in Neovim

**Implementation**: Add to plugins
```nix
# neovim.nix
octo-nvim
```

```lua
-- plugins/octo.lua
return {
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    keys = {
      { "<leader>go", "<cmd>Octo<cr>", desc = "Open Octo" },
    },
    opts = {
      use_local_fs = true,
    },
  },
}
```

**Benefits**:
- Review PRs in Neovim
- Manage issues
- Comment on code

**Recommendation**: ⭐⭐⭐⭐ Useful for GitHub workflow

---

### 4. mini.test
**Location**: `repos/dot/nvim/lua/plugins/coding.lua:40`

**Description**: Run tests conditionally if tests/ directory exists

**Implementation**:
```lua
-- plugins/mini.lua (add to existing)
{
  "echasnovski/mini.nvim",
  config = function()
    require("mini.align").setup()
    if vim.fn.isdirectory("tests") == 1 then
      require("mini.test").setup()
    end
  end,
}
```

**Recommendation**: ⭐⭐ Optional (only if writing Neovim plugins)

---

### 5. lazydev.nvim
**Location**: `repos/dot/nvim/lua/plugins/coding.lua:42-53`

**Description**: Better Lua development for Neovim plugins (luassert, busted)

**Implementation**:
```nix
# neovim.nix
lazydev-nvim
```

```lua
-- plugins/lazydev.lua
return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
}
```

**Benefits**:
- Better autocomplete for Neovim API
- Type hints for Lua

**Recommendation**: ⭐⭐⭐⭐ Recommended for Neovim config development

---

### 6. peek.nvim
**Location**: `repos/dot/nvim/lua/plugins/coding.lua:57-71`

**Description**: Markdown preview with Deno

**Depends on**: deno

**Implementation**:
```nix
# neovim.nix extraPackages
deno
```

```lua
-- plugins/peek.lua
return {
  {
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    ft = "markdown",
    opts = {
      theme = "dark",
    },
    keys = {
      {
        "<leader>mp",
        function()
          require("peek").open()
        end,
        desc = "Markdown Preview",
      },
    },
  },
}
```

**Recommendation**: ⭐⭐⭐ Good for markdown editing

---

### 7. Noice.nvim Advanced Config
**Location**: `repos/dot/nvim/lua/plugins/ui.lua:15-64`

**Features**:
- Filter "No information available" notifications
- Focus-aware notifications
- Markdown keybindings

**Implementation**: Update existing noice.lua
```lua
opts = function(_, opts)
  opts.routes = opts.routes or {}

  -- filter_no_information_available
  table.insert(opts.routes, {
    filter = {
      event = "notify",
      find = "No information available",
    },
    opts = { skip = true },
  })

  -- markdown_keybindings
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function(event)
      vim.schedule(function()
        require("noice.text.markdown").keys(event.buf)
      end)
    end,
  })

  return opts
end
```

**Recommendation**: ⭐⭐⭐⭐ Improves UX

---

### 8. lualine.nvim
**Location**: `repos/dot/nvim/lua/plugins/ui.lua:67-141`

**Description**: Status line (alternative to none)

**Note**: mutagen-specific code can be ignored

**Implementation**:
```nix
# neovim.nix
lualine-nvim
```

```lua
-- plugins/lualine.lua
return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "tokyonight",
        component_separators = "|",
        section_separators = "",
      },
    },
  },
}
```

**Recommendation**: ⭐⭐⭐⭐⭐ Essential (status line)

---

### 9. Additional Keymaps
**Location**: `repos/dot/nvim/lua/config/keymaps.lua:6`

**Feature**: `<C-c>` mapped to `ciw` (change inner word)

**Implementation**: Add to config/keymaps.lua
```lua
vim.keymap.set("n", "<C-c>", "ciw", { desc = "Change inner word" })
```

**Recommendation**: ⭐⭐⭐ Convenient shortcut

---

### 10. AI Plugins (sidekick, codecompanion, minuet)
**Location**: `repos/dot/nvim/lua/plugins/ai.lua`

**Description**: AI completion and chat

**Status**: Disabled in source config

**Recommendation**: ⭐ Skip (already have claude-code)

---

## 📝 Summary

### High Priority (Implement Now) ⭐⭐⭐⭐⭐
1. **lualine.nvim** - Essential status line

### Medium-High Priority ⭐⭐⭐⭐
2. **lazydev.nvim** - Better Lua development
3. **octo.nvim** - GitHub integration
4. **Noice advanced config** - UX improvements

### Medium Priority ⭐⭐⭐
5. **Cowboy mode** - Educational/fun
6. **peek.nvim** - Markdown preview
7. **`<C-c>` keymap** - Convenience

### Low Priority ⭐⭐
8. **mini.test** - Plugin development only

### Skip ⭐
9. ts-comments (redundant)
10. AI plugins (disabled, have alternatives)

---

## 🎯 Recommended Implementation Order

1. lualine.nvim (essential)
2. Noice improvements (quick wins)
3. `<C-c>` keymap (1 line)
4. lazydev.nvim (config development)
5. Cowboy mode (fun feature)
6. octo.nvim (if using GitHub actively)
7. peek.nvim (if writing markdown)

---

## 📦 Total New Plugins Needed

**Essential**:
- lualine-nvim
- lazydev-nvim

**Optional**:
- octo-nvim
- peek.nvim (+ deno)

**Total**: 2-4 new plugins
