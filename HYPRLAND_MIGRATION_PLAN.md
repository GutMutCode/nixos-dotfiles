# Hyprland Configuration Migration Plan

## Overview
This document outlines the step-by-step plan to migrate useful Hyprland configurations from analyzed repositories to the current NixOS environment.

**Source Repositories:**
- `/home/gmc/nixos-dotfiles/repos/Hyprland-Dots` (Primary source - most comprehensive)
- `/home/gmc/nixos-dotfiles/repos/HyDE` (Theming and modern features)
- `/home/gmc/nixos-dotfiles/repos/dotfiles/peak_poetry` (Advanced window management)
- `/home/gmc/nixos-dotfiles/repos/dotfiles/` (Various theme implementations)

**Target Location:**
- Configuration base: `/home/gmc/nixos-dotfiles/config/hypr/`
- NixOS integration: `/home/gmc/nixos-dotfiles/home.nix` or `/home/gmc/nixos-dotfiles/configuration.nix`

---

## Phase 1: Core Configuration Structure

### 1.1 Directory Structure Setup
**Task:** Create modular directory structure for Hyprland configs
```
/home/gmc/nixos-dotfiles/config/hypr/
├── hyprland.conf              # Main config (imports all modules)
├── animations/                # Animation configurations
├── keybinds/                  # Keybinding configurations
├── rules/                     # Window and layer rules
├── settings/                  # General settings
├── scripts/                   # Utility scripts
└── themes/                    # Visual themes and shaders
```

**Reference:**
- Hyprland-Dots structure: `/home/gmc/nixos-dotfiles/repos/Hyprland-Dots/config/hypr/`
- HyDE structure: `/home/gmc/nixos-dotfiles/repos/HyDE/Configs/.config/hypr/`

### 1.2 Environment Variables
**Task:** Create comprehensive environment variable configuration

**Source File:** `/home/gmc/nixos-dotfiles/repos/Hyprland-Dots/config/hypr/UserConfigs/ENVariables.conf`

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/settings/environment.conf`

**Key Variables to Include:**
```conf
# Toolkit Backends
env = GDK_BACKEND,wayland,x11,*
env = QT_QPA_PLATFORM,wayland;xcb
env = SDL_VIDEODRIVER,wayland
env = CLUTTER_BACKEND,wayland

# XDG Specifications
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_TYPE,wayland
env = XDG_SESSION_DESKTOP,Hyprland

# Qt Theming
env = QT_AUTO_SCREEN_SCALE_FACTOR,1
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1

# Electron Apps
env = ELECTRON_OZONE_PLATFORM_HINT,auto

# Cursor
env = HYPRCURSOR_THEME,<theme-name>
env = HYPRCURSOR_SIZE,24

# NVIDIA (if applicable - commented by default)
# env = LIBVA_DRIVER_NAME,nvidia
# env = __GLX_VENDOR_LIBRARY_NAME,nvidia
```

**Dependencies:** None - pure configuration

---

## Phase 2: Keybindings Enhancement

### 2.1 Keycode-Based Bindings
**Task:** Migrate to keycode-based bindings for better keyboard layout compatibility

**Source File:** `/home/gmc/nixos-dotfiles/repos/Hyprland-Dots/config/hypr/configs/Keybinds.conf`

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/keybinds/workspaces.conf`

**Implementation:**
```conf
# Workspace bindings using keycodes (code:10 = key 1, code:11 = key 2, etc.)
bind = $mainMod, code:10, workspace, 1
bind = $mainMod, code:11, workspace, 2
# ... up to code:19 for workspace 10

# Silent workspace moves (don't follow window)
bind = $mainMod CTRL, code:10, movetoworkspacesilent, 1
bind = $mainMod CTRL, code:11, movetoworkspacesilent, 2
# ... etc.

# Workspace cycling
bind = $mainMod, Tab, workspace, e+1
bind = $mainMod SHIFT, Tab, workspace, e-1

# Relative workspace movement
bind = $mainMod CTRL, bracketleft, workspace, e-1
bind = $mainMod CTRL, bracketright, workspace, e+1
```

**Dependencies:** None

### 2.2 Advanced Window Controls
**Task:** Add resize submap and group controls

**Source File:** `/home/gmc/nixos-dotfiles/repos/dotfiles/peak_poetry/config/hypr/hyprland.conf`

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/keybinds/window-controls.conf`

**Implementation:**
```conf
# Resize submap
bind = ALT, R, submap, resize
submap = resize
binde = , h, resizeactive, -10 0
binde = , j, resizeactive, 0 10
binde = , k, resizeactive, 0 -10
binde = , l, resizeactive, 10 0
bind = , escape, submap, reset
submap = reset

# Group (tabbed) controls
bind = $mainMod, G, togglegroup
bind = $mainMod CTRL, H, moveintogroup, l
bind = $mainMod CTRL, J, moveintogroup, d
bind = $mainMod CTRL, K, moveintogroup, u
bind = $mainMod CTRL, L, moveintogroup, r
bind = ALT, Tab, changegroupactive, f
bind = ALT SHIFT, Tab, changegroupactive, b
```

**Dependencies:** None

### 2.3 Utility Keybindings
**Task:** Add emoji picker, glyph picker, and enhanced clipboard

**Source Files:**
- HyDE: `/home/gmc/nixos-dotfiles/repos/HyDE/Configs/.config/hypr/keybindings.conf`
- Hyprland-Dots: Various script keybinds

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/keybinds/utilities.conf`

**Implementation:**
```conf
# Quick access utilities
bind = $mainMod, comma, exec, rofi -show emoji
bind = $mainMod, period, exec, rofi -show symbols
bind = $mainMod, V, exec, cliphist list | head -1 | cliphist decode | wl-copy
bind = $mainMod SHIFT, V, exec, ~/.config/hypr/scripts/clipboard-manager.sh
bind = $mainMod, slash, exec, ~/.config/hypr/scripts/keyhints.sh

# Do Not Disturb
bind = $mainMod, D, exec, ~/.config/hypr/scripts/dnd-toggle.sh
```

**Dependencies:**
- `rofi` with emoji/symbols support
- `cliphist`
- `wl-clipboard`
- Custom scripts (Phase 4)

---

## Phase 3: Window Rules Enhancement

### 3.1 Tag-Based Window Rules System
**Task:** Implement tag-based window rule organization

**Source File:** `/home/gmc/nixos-dotfiles/repos/Hyprland-Dots/config/hypr/UserConfigs/WindowRules.conf`

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/rules/window-rules.conf`

**Implementation Structure:**
```conf
# Define application tags
windowrulev2 = tag +browser, class:^(firefox|chromium|brave|vivaldi)$
windowrulev2 = tag +terminal, class:^(kitty|alacritty|foot|wezterm)$
windowrulev2 = tag +projects, class:^(code|jetbrains|idea|pycharm)$
windowrulev2 = tag +im, class:^(discord|telegram|signal|slack)$
windowrulev2 = tag +media, class:^(mpv|vlc|spotify)$
windowrulev2 = tag +games, class:^(steam|lutris|heroic)$

# Workspace assignments by tag
windowrulev2 = workspace 2, tag:browser
windowrulev2 = workspace 3, tag:projects
windowrulev2 = workspace 4, tag:im
windowrulev2 = workspace 5, tag:media
windowrulev2 = workspace 6, tag:games

# Opacity by tag
windowrulev2 = opacity 0.95 0.85, tag:terminal
windowrulev2 = opacity 0.98 0.90, tag:browser
windowrulev2 = opacity 1.0 1.0, tag:games
windowrulev2 = opacity 1.0 1.0, tag:media

# Special rules
windowrulev2 = noinitialfocus, class:^(.*jetbrains.*)$, title:^(win[0-9]+)$
windowrulev2 = float, title:^(Picture-in-Picture)$
windowrulev2 = size 25% 25%, title:^(Picture-in-Picture)$
windowrulev2 = move 73% 72%, title:^(Picture-in-Picture)$
windowrulev2 = pin, title:^(Picture-in-Picture)$
```

**Dependencies:** None - pure configuration

### 3.2 Layer Rules for UI Elements
**Task:** Add blur and transparency for Wayland layers

**Source Files:**
- HyDE: `/home/gmc/nixos-dotfiles/repos/HyDE/Configs/.config/hypr/windowrules.conf`
- peak_poetry: `/home/gmc/nixos-dotfiles/repos/dotfiles/peak_poetry/config/hypr/hyprland.conf`

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/rules/layer-rules.conf`

**Implementation:**
```conf
# Launcher blur
layerrule = blur, rofi
layerrule = blur, anyrun
layerrule = ignorezero, rofi
layerrule = ignorezero, anyrun

# Notification blur
layerrule = blur, notifications
layerrule = blur, swaync-control-center
layerrule = ignorezero, notifications

# Bar blur
layerrule = blur, waybar
layerrule = ignorezero, waybar

# Logout/lock screen
layerrule = blur, logout_dialog
layerrule = blur, lockscreen
```

**Dependencies:**
- Hyprland blur enabled in general settings
- Applications: rofi/anyrun, mako/dunst/swaync, waybar

---

## Phase 4: Scripts and Utilities

### 4.1 Dropdown Terminal
**Task:** Implement sophisticated dropdown terminal with animations

**Source File:** `/home/gmc/nixos-dotfiles/repos/Hyprland-Dots/config/hypr/scripts/Dropterminal.sh`

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/scripts/dropdown-terminal.sh`

**Features to Implement:**
- Configurable terminal emulator (kitty/alacritty/foot)
- Smooth slide animations
- Multi-monitor support (follows focus)
- Persistent state
- Size/position configuration (percentage-based)

**Keybind:**
```conf
bind = $mainMod, grave, exec, ~/.config/hypr/scripts/dropdown-terminal.sh
```

**Dependencies:**
- `socat` or `hyprctl` for IPC
- Terminal emulator of choice
- Window rule for dropdown class

### 4.2 Game Mode Toggle
**Task:** Create performance mode toggle script

**Source Files:**
- Hyprland-Dots: `/home/gmc/nixos-dotfiles/repos/Hyprland-Dots/config/hypr/scripts/GameMode.sh`
- HyDE: `/home/gmc/nixos-dotfiles/repos/HyDE/Configs/.local/lib/hyde/gamemode.sh`

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/scripts/gamemode.sh`

**Features:**
- Toggle animations (on/off)
- Toggle blur (on/off)
- Toggle shadows (on/off)
- Set gaps to 0 (or restore)
- Set rounding to 0 (or restore)
- Set all windows to opaque (or restore)
- Minimal border width
- Stop wallpaper daemon (optional)
- Disable waybar animations

**Keybind:**
```conf
bind = $mainMod SHIFT, G, exec, ~/.config/hypr/scripts/gamemode.sh
```

**Dependencies:**
- `hyprctl` for runtime configuration
- `notify-send` for user feedback

### 4.3 Advanced Clipboard Manager
**Task:** Implement clipboard manager with delete functionality

**Source File:** `/home/gmc/nixos-dotfiles/repos/Hyprland-Dots/config/hypr/scripts/ClipManager.sh`

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/scripts/clipboard-manager.sh`

**Features:**
- Show clipboard history via rofi
- `Ctrl + Delete` - Delete single entry
- `Alt + Delete` - Wipe all history
- Custom rofi theme integration

**Dependencies:**
- `cliphist` daemon (must be running)
- `rofi` with custom keybind support
- `wl-clipboard`

### 4.4 Wallpaper Dynamic Theming
**Task:** Implement wallust-based dynamic theming

**Source File:** `/home/gmc/nixos-dotfiles/repos/Hyprland-Dots/config/hypr/scripts/WallustSwww.sh`

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/scripts/wallpaper-theme.sh`

**Features:**
- Extract colors from wallpaper using wallust
- Update Hyprland colors
- Update waybar theme
- Update rofi theme
- Update terminal colors
- Per-monitor wallpaper tracking
- Template regeneration

**Dependencies:**
- `wallust` - color extraction
- `swww` - wallpaper daemon
- `magick` (ImageMagick) - image processing
- Template files for each application

### 4.5 Keybindings Hint Menu
**Task:** Create interactive keybinding reference

**Source File:** `/home/gmc/nixos-dotfiles/repos/Hyprland-Dots/config/hypr/scripts/KeyHints.sh`

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/scripts/keyhints.sh`

**Features:**
- Parse keybinding config files
- Display in searchable YAD dialog
- Show key, description, command
- Custom styling

**Alternative:** Use HyDE's `bindd` approach with `Super + /` rofi menu

**Dependencies:**
- `yad` or `rofi` for display
- Parse logic for hyprland.conf

### 4.6 Screenshot with OCR
**Task:** Advanced screenshot system

**Source File:** `/home/gmc/nixos-dotfiles/repos/HyDE/Configs/.local/lib/hyde/screenshot.sh`

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/scripts/screenshot.sh`

**Features:**
- Area selection with frozen preview
- Full screen capture
- Active window capture
- OCR text extraction (Tesseract)
- Copy to clipboard option
- Save to file option

**Dependencies:**
- `grim` - screenshot utility
- `slurp` - area selection
- `tesseract` - OCR
- `wl-clipboard`
- `satty` or `swappy` - annotation (optional)

### 4.7 Do Not Disturb Toggle
**Task:** Simple DND mode toggle

**Implementation:** New script

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/scripts/dnd-toggle.sh`

**Features:**
- Toggle notification daemon (mako/dunst/swaync)
- Visual indicator (waybar module or notify-send)
- Persistent state

**Dependencies:**
- `makoctl` or `dunstctl` or `swaync-client`

---

## Phase 5: Animations and Visual Effects

### 5.1 Optimized Animations Profile
**Task:** Create balanced animation configuration

**Source File:** `/home/gmc/nixos-dotfiles/repos/Hyprland-Dots/config/hypr/animations/HYDE - optimized.conf`

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/animations/optimized.conf`

**Implementation:**
```conf
animations {
    enabled = yes

    bezier = wind, 0.05, 0.9, 0.1, 1.0
    bezier = winIn, 0.1, 1.1, 0.1, 1.0
    bezier = winOut, 0.3, -0.3, 0, 1
    bezier = liner, 1, 1, 1, 1

    animation = windows, 1, 6, wind, slide
    animation = windowsIn, 1, 6, winIn, popin 60%
    animation = windowsOut, 1, 5, winOut, slide
    animation = windowsMove, 1, 5, wind, slide

    animation = border, 1, 1, liner
    animation = borderangle, 1, 180, liner, loop

    animation = fade, 1, 10, default
    animation = workspaces, 1, 5, wind, slidefadevert 15%
    animation = specialWorkspace, 1, 5, wind, slidevert

    animation = layers, 1, 3, default, popin 80%
}
```

**Dependencies:** None - pure configuration

### 5.2 Material Design 3 Animations (Alternative)
**Task:** Create MD3-inspired animation profile

**Source File:** `/home/gmc/nixos-dotfiles/repos/Hyprland-Dots/config/hypr/animations/END-4.conf`

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/animations/md3.conf`

**Implementation:**
```conf
animations {
    enabled = yes

    bezier = md3_standard, 0.2, 0.0, 0, 1.0
    bezier = md3_decel, 0.05, 0.7, 0.1, 1
    bezier = md3_accel, 0.3, 0, 0.8, 0.15
    bezier = menu_decel, 0.1, 1, 0, 1

    animation = windows, 1, 4, md3_standard, popin 60%
    animation = windowsIn, 1, 4, md3_decel, popin 60%
    animation = windowsOut, 1, 4, md3_accel, popin 60%
    animation = border, 1, 10, default
    animation = fade, 1, 2.5, md3_decel
    animation = workspaces, 1, 7, menu_decel, slide
    animation = specialWorkspace, 1, 7, md3_decel, slidevert
}
```

**Dependencies:** None - pure configuration

### 5.3 Screen Shaders
**Task:** Add visual accessibility shaders

**Source Directory:** `/home/gmc/nixos-dotfiles/repos/HyDE/Configs/.config/hypr/shaders/`

**Target Directory:** `/home/gmc/nixos-dotfiles/config/hypr/shaders/`

**Shaders to Copy:**
- `blue-light-filter.frag` - Night mode
- `grayscale.frag` - Monochrome accessibility
- `vibrance.frag` - Color enhancement
- `invert-colors.frag` - Color inversion

**Usage Keybinds:**
```conf
bind = $mainMod SHIFT, B, exec, hyprctl keyword decoration:screen_shader ~/.config/hypr/shaders/blue-light-filter.frag
bind = $mainMod SHIFT, G, exec, hyprctl keyword decoration:screen_shader ~/.config/hypr/shaders/grayscale.frag
bind = $mainMod SHIFT, N, exec, hyprctl keyword decoration:screen_shader "" # Reset
```

**Dependencies:** Shader files only

---

## Phase 6: General Settings Optimization

### 6.1 Performance and UX Settings
**Task:** Apply optimized general settings

**Source Files:**
- Hyprland-Dots: `/home/gmc/nixos-dotfiles/repos/Hyprland-Dots/config/hypr/UserConfigs/UserSettings.conf`
- peak_poetry: Various settings

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/settings/general.conf`

**Key Settings:**
```conf
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    resize_on_border = true
    extend_border_grab_area = 15
    hover_icon_on_border = true
    layout = dwindle
    allow_tearing = false
}

decoration {
    rounding = 10

    active_opacity = 1.0
    inactive_opacity = 0.95

    blur {
        enabled = true
        size = 8
        passes = 2
        ignore_opacity = true
        new_optimizations = true
        xray = true
    }

    drop_shadow = true
    shadow_range = 20
    shadow_render_power = 3
}

input {
    kb_layout = us
    follow_mouse = 1
    mouse_refocus = false

    touchpad {
        natural_scroll = true
        disable_while_typing = true
        tap-to-click = true
    }

    sensitivity = 0
}

gestures {
    workspace_swipe = true
    workspace_swipe_fingers = 3
    workspace_swipe_distance = 300
    workspace_swipe_cancel_ratio = 0.5
}

misc {
    disable_hyprland_logo = true
    disable_splash_rendering = true
    force_default_wallpaper = 0

    vrr = 2  # Adaptive sync
    vfr = true  # Variable frame rate

    mouse_move_enables_dpms = true
    key_press_enables_dpms = true

    enable_swallow = false  # Terminal swallowing (optional)
    swallow_regex = ^(kitty|alacritty)$

    middle_click_paste = false  # Disable annoying middle-click paste

    background_color = 0x1a1b26

    new_window_takes_over_fullscreen = 2
}

binds {
    workspace_back_and_forth = true
    allow_workspace_cycles = true
    pass_mouse_when_bound = false
}

cursor {
    no_cursor_timeouts = false
    inactive_timeout = 5
    no_warps = false
    warp_on_change_workspace = 2
}

debug {
    disable_logs = false
    anr_missed_pings = 15  # Prevent false ANR alerts
}
```

**Dependencies:** None - pure configuration

---

## Phase 7: NixOS Integration

### 7.1 Package Dependencies
**Task:** Ensure all required packages are installed via Nix

**Target File:** `/home/gmc/nixos-dotfiles/home.nix` or `configuration.nix`

**Required Packages:**
```nix
home.packages = with pkgs; [
  # Core Hyprland utilities
  hyprpaper          # or swww for wallpaper
  hyprpicker         # Color picker

  # Clipboard
  cliphist
  wl-clipboard

  # Screenshot
  grim
  slurp
  satty              # or swappy for annotation
  tesseract          # OCR

  # Notifications
  mako               # or dunst or swaync
  libnotify          # notify-send

  # Launcher
  rofi-wayland       # or anyrun

  # Theming
  wallust            # Color extraction
  imagemagick        # Image processing

  # Terminal (choose one)
  kitty              # or alacritty, foot, wezterm

  # Display info
  wlr-randr

  # Session management
  wlogout            # Logout menu

  # Screen sharing (optional)
  xdg-desktop-portal-hyprland

  # Utilities
  socat              # IPC for scripts
  jq                 # JSON parsing
  yad                # Dialogs
  bc                 # Calculator for scripts
];
```

### 7.2 Systemd Services
**Task:** Set up required background services

**Target File:** `/home/gmc/nixos-dotfiles/home.nix`

**Services to Enable:**
```nix
systemd.user.services = {
  # Clipboard history daemon
  cliphist = {
    Unit = {
      Description = "Clipboard history daemon";
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
    };
    Install.WantedBy = ["graphical-session.target"];
  };

  # Wallpaper daemon (if using swww)
  swww-daemon = {
    Unit = {
      Description = "Wallpaper daemon";
      PartOf = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.swww}/bin/swww-daemon";
      Restart = "on-failure";
    };
    Install.WantedBy = ["graphical-session.target"];
  };
};
```

### 7.3 XDG Autostart
**Task:** Configure autostart applications

**Target File:** `/home/gmc/nixos-dotfiles/home.nix`

**Autostart Items:**
```nix
# In wayland.windowManager.hyprland.settings or hyprland.conf
exec-once = [
  "waybar"
  "mako"  # or dunst/swaync
  "nm-applet"
  "blueman-applet"
  "wl-paste --watch cliphist store"  # If not using systemd service
  "swww-daemon"  # If not using systemd service
  "~/.config/hypr/scripts/wallpaper-theme.sh"  # Initial theme setup
];
```

### 7.4 Symlink Configuration
**Task:** Ensure Hyprland configs are properly symlinked

**Target File:** `/home/gmc/nixos-dotfiles/home.nix`

**Symlink Setup:**
```nix
xdg.configFile = {
  "hypr".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/nixos-dotfiles/config/hypr";
};
```

**Verify existing:** Check if this is already configured in home.nix

---

## Phase 8: Laptop-Specific Configuration (Optional)

### 8.1 Laptop Controls
**Task:** Add laptop-specific keybindings and settings

**Source File:** `/home/gmc/nixos-dotfiles/repos/Hyprland-Dots/config/hypr/UserConfigs/Laptops.conf`

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/settings/laptop.conf`

**Implementation:**
```conf
# Only source this file on laptop systems

# Brightness controls
binde = , XF86MonBrightnessUp, exec, brightnessctl set +5%
binde = , XF86MonBrightnessDown, exec, brightnessctl set 5%-

# Keyboard backlight
binde = , XF86KbdBrightnessUp, exec, brightnessctl --device=*kbd_backlight set +10%
binde = , XF86KbdBrightnessDown, exec, brightnessctl --device=*kbd_backlight set 10%-

# Touchpad toggle
bind = , XF86TouchpadToggle, exec, ~/.config/hypr/scripts/touchpad-toggle.sh

# Lid switch handling
bindl = , switch:Lid Switch, exec, ~/.config/hypr/scripts/lid-handler.sh
```

**Dependencies:**
- `brightnessctl`
- Laptop detection script
- Lid handler script

### 8.2 Conditional Loading
**Task:** Only load laptop config on laptop systems

**Implementation in main hyprland.conf:**
```conf
# Detect if laptop
exec-once = [[ -f /sys/class/power_supply/BAT0 ]] && hyprctl keyword source ~/.config/hypr/settings/laptop.conf
```

Or in NixOS config:
```nix
# In home.nix or configuration.nix
wayland.windowManager.hyprland.extraConfig = lib.optionalString
  (builtins.pathExists "/sys/class/power_supply/BAT0")
  "source = ~/.config/hypr/settings/laptop.conf";
```

---

## Phase 9: Testing and Validation

### 9.1 Configuration Validation
**Task:** Test Hyprland config syntax before applying

**Commands:**
```bash
# Validate config syntax (Hyprland will check on reload)
hyprctl reload

# Check for errors
journalctl --user -u hyprland -f

# Test individual scripts
~/.config/hypr/scripts/dropdown-terminal.sh
~/.config/hypr/scripts/gamemode.sh
~/.config/hypr/scripts/clipboard-manager.sh
```

### 9.2 Incremental Testing Plan
**Order of Implementation:**

1. **Phase 1 & 2** - Core structure and keybindings (low risk)
2. **Phase 6** - General settings (test performance impact)
3. **Phase 3** - Window rules (test app behavior)
4. **Phase 5** - Animations (test visual appearance)
5. **Phase 4** - Scripts (test functionality one by one)
6. **Phase 7** - NixOS integration (rebuild system)
7. **Phase 8** - Laptop features (if applicable)

### 9.3 Rollback Plan
**Task:** Ensure ability to rollback changes

**Approach:**
1. Commit current working config to git before changes
2. Create backup: `cp -r ~/.config/hypr ~/.config/hypr.backup`
3. For NixOS: Previous generation available via `nixos-rebuild switch --rollback`
4. Keep old hyprland.conf commented out until new config is stable

---

## Phase 10: Documentation and Maintenance

### 10.1 Personal Documentation
**Task:** Document custom keybindings and features

**Target File:** `/home/gmc/nixos-dotfiles/config/hypr/README.md`

**Contents:**
- Keybinding reference table
- Script descriptions and usage
- Configuration structure overview
- Customization guide
- Troubleshooting section

### 10.2 Update Existing Docs
**Task:** Update CLAUDE.md with Hyprland information

**Target File:** `/home/gmc/nixos-dotfiles/CLAUDE.md`

**Add Section:**
```markdown
### Hyprland Configuration
- **Main config**: `/home/gmc/nixos-dotfiles/config/hypr/hyprland.conf`
- **Reload config**: `hyprctl reload`
- **View active config**: `hyprctl -j getoption <option>`
- **Script location**: `~/.config/hypr/scripts/`
- **Module structure**: Modular config in `~/.config/hypr/{animations,keybinds,rules,settings}/`
```

---

## Implementation Checklist

### Prerequisites
- [ ] Backup current Hyprland configuration
- [ ] Commit current working state to git
- [ ] Verify all source repositories are accessible
- [ ] Review NixOS configuration structure

### Phase 1: Core Structure
- [ ] Create directory structure
- [ ] Set up environment variables config
- [ ] Update main hyprland.conf to source modules

### Phase 2: Keybindings
- [ ] Implement keycode-based workspace bindings
- [ ] Add resize submap and group controls
- [ ] Configure utility keybindings
- [ ] Test all keybindings work as expected

### Phase 3: Window Rules
- [ ] Implement tag-based window rule system
- [ ] Configure layer rules for UI elements
- [ ] Test window behavior and assignments

### Phase 4: Scripts
- [ ] Implement dropdown terminal script
- [ ] Create game mode toggle script
- [ ] Set up advanced clipboard manager
- [ ] Configure wallpaper dynamic theming
- [ ] Build keybindings hint menu
- [ ] Add screenshot with OCR support
- [ ] Create DND toggle script
- [ ] Make all scripts executable (`chmod +x`)
- [ ] Test each script individually

### Phase 5: Animations & Visuals
- [ ] Configure optimized animations
- [ ] Copy and test screen shaders
- [ ] Verify animation performance

### Phase 6: Settings
- [ ] Apply optimized general settings
- [ ] Test performance impact
- [ ] Adjust settings as needed

### Phase 7: NixOS Integration
- [ ] Add all required packages to home.nix/configuration.nix
- [ ] Configure systemd services
- [ ] Set up XDG autostart
- [ ] Verify symlink configuration
- [ ] Run `nixos-rebuild switch` or `home-manager switch`

### Phase 8: Laptop Config (If Applicable)
- [ ] Create laptop-specific configuration
- [ ] Implement conditional loading
- [ ] Test laptop features

### Phase 9: Testing
- [ ] Validate all configuration syntax
- [ ] Test keybindings comprehensively
- [ ] Verify all scripts function correctly
- [ ] Check window rules behavior
- [ ] Test animations and visual effects
- [ ] Monitor system logs for errors

### Phase 10: Documentation
- [ ] Create Hyprland config README
- [ ] Update CLAUDE.md with Hyprland section
- [ ] Document custom keybindings
- [ ] Add troubleshooting notes

### Final Steps
- [ ] Clean up temporary files
- [ ] Remove unused configurations
- [ ] Commit all changes to git
- [ ] Create git tag for this configuration milestone

---

## Quick Reference

### File Locations
| Purpose | Source | Target |
|---------|--------|--------|
| Main config | Various | `/home/gmc/nixos-dotfiles/config/hypr/hyprland.conf` |
| Keybindings | Hyprland-Dots | `/home/gmc/nixos-dotfiles/config/hypr/keybinds/` |
| Window rules | Hyprland-Dots | `/home/gmc/nixos-dotfiles/config/hypr/rules/` |
| Animations | Hyprland-Dots | `/home/gmc/nixos-dotfiles/config/hypr/animations/` |
| Scripts | Multiple | `/home/gmc/nixos-dotfiles/config/hypr/scripts/` |
| Shaders | HyDE | `/home/gmc/nixos-dotfiles/config/hypr/shaders/` |

### Key Dependencies
- Core: `hyprland`, `hyprpaper`/`swww`, `waybar`
- Clipboard: `cliphist`, `wl-clipboard`
- Screenshot: `grim`, `slurp`, `tesseract`
- Theming: `wallust`, `imagemagick`
- Utilities: `rofi-wayland`, `mako`, `socat`, `jq`

### Useful Commands
```bash
# Reload Hyprland config
hyprctl reload

# Test script
bash -x ~/.config/hypr/scripts/script-name.sh

# Check Hyprland logs
journalctl --user -u hyprland -f

# Query current settings
hyprctl -j getoption general:gaps_in

# List all windows
hyprctl -j clients

# NixOS rebuild
sudo nixos-rebuild switch --flake .#nixos-gmc
```

---

## Notes for LLM Context

### Parsing Instructions
1. **File paths** are absolute and follow the pattern `/home/gmc/nixos-dotfiles/config/hypr/...`
2. **Source files** reference the repos directory: `/home/gmc/nixos-dotfiles/repos/{repo-name}/...`
3. **Code blocks** marked with language identifiers (conf, nix, bash) for proper syntax
4. **Dependencies** listed explicitly for each component
5. **Phases** are numbered and should be executed in order
6. **Checklist items** can be used to track progress

### Key Concepts
- **Tag-based rules**: Use `windowrulev2 = tag +name, criteria` then apply rules to tags
- **Keycode bindings**: Use `code:XX` instead of key names for layout independence
- **Modular structure**: Split config into logical modules under subdirectories
- **NixOS integration**: All system packages must be declared in Nix config
- **Conditional loading**: Laptop configs only loaded when hardware detected

### Priority Items
High priority (implement first):
- Environment variables (Phase 1.2)
- Keycode bindings (Phase 2.1)
- Tag-based window rules (Phase 3.1)
- Game mode script (Phase 4.2)
- General settings (Phase 6.1)

Medium priority:
- Dropdown terminal (Phase 4.1)
- Advanced clipboard (Phase 4.3)
- Animations (Phase 5)
- Layer rules (Phase 3.2)

Low priority (nice to have):
- Wallpaper theming (Phase 4.4)
- Screen shaders (Phase 5.3)
- Laptop configs (Phase 8)

### Common Pitfalls
1. Scripts must be executable: `chmod +x ~/.config/hypr/scripts/*.sh`
2. Systemd services need full paths to binaries (use `${pkgs.package}/bin/binary` in Nix)
3. Window rules are processed in order - specific rules should come before general ones
4. Cliphist daemon must be running before clipboard manager script works
5. Wallust requires template files for each application to theme

### Testing Strategy
1. Test each phase independently before moving to next
2. Use `hyprctl reload` to apply config changes without restarting
3. Monitor `journalctl --user -u hyprland -f` for errors
4. Test scripts with `bash -x` flag for debugging
5. Keep backup config accessible for quick rollback

---

## End of Migration Plan

This plan provides a comprehensive, step-by-step guide to migrating Hyprland configurations. Each phase is independent and can be implemented incrementally. The structure is designed for easy parsing by LLMs while remaining human-readable.
