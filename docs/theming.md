# Theming Guide

Instructions for customizing the wallust theming system.

## Table of Contents

1. [Adding New Themes to Theme Picker](#adding-new-themes-to-theme-picker)
2. [Customizing Wallust Templates](#customizing-wallust-templates)
3. [Creating Custom Themes](#creating-custom-themes)
4. [Testing Theme Changes](#testing-theme-changes)

## Adding New Themes to Theme Picker

### Location
`~/nixos-dotfiles/config/hypr/scripts/theme-picker.sh`

### Step 1: Find Available Themes

Wallust has 700+ built-in themes. To browse them:

```bash
wallust theme --help
wallust theme --help | grep -i gruvbox
```

### Step 2: Add Theme to Picker

Edit `theme-picker.sh` and add your theme to the `POPULAR_THEMES` array:

```bash
POPULAR_THEMES=(
    "Tokyo-Night"
    "Catppuccin-Mocha"
    "Gruvbox-Dark"
    "Nord"
    "Dracula"
    "Rose-Pine"
    "Your-New-Theme"
)
```

**Important:**
- Theme names are case-sensitive
- Use exact names from `wallust theme --help`
- One theme per line for readability

### Step 3: Test the New Theme

```bash
~/.config/hypr/scripts/theme-picker.sh
```

### Step 4: Apply to NixOS (Optional)

If you modified the script and want changes to persist:

```bash
cd ~/nixos-dotfiles
sudo nixos-rebuild switch --flake .#nixos-gmc
```

## Customizing Wallust Templates

### Template Locations

All templates are in `~/nixos-dotfiles/config/wallust/templates/`:

```
templates/
├── hyprland-colors.conf
├── alacritty-colors.toml
├── waybar-colors.css
├── rofi-colors.rasi
└── mako-colors
```

### Template Syntax

Wallust uses `{{variable}}` syntax for color substitution:

**Available Variables:**
```
{{background}}     # Main background color (#RRGGBB)
{{foreground}}     # Main text color (#RRGGBB)
{{cursor}}         # Cursor color (#RRGGBB)

{{color0}}  - {{color15}}    # 16-color palette
  color0  = Background (darkest)
  color1  = Red
  color2  = Green
  color3  = Yellow
  color4  = Blue
  color5  = Magenta
  color6  = Cyan
  color7  = Foreground
  color8  = Bright Black / Dim
  color9  = Bright Red
  color10 = Bright Green
  color11 = Bright Yellow
  color12 = Bright Blue
  color13 = Bright Magenta
  color14 = Bright Cyan
  color15 = Bright White
```

### Example: Customizing Rofi Template

**File:** `config/wallust/templates/rofi-colors.rasi`

```rasi
* {
    background:     {{background}};
    background-alt: {{color0}};
    foreground:     {{foreground}};
    selected:       {{color4}};
    active:         {{color2}};
    urgent:         {{color1}};
    accent:         {{color4}};
    border-color:   {{color4}};
    separatorcolor: {{color8}};
    highlight:      {{color6}};
    text-secondary: {{color7}};
    selected-text:  {{color15}};
}
```

**To customize:**
1. Edit the template file
2. Change color mappings (e.g., `{{color4}}` → `{{color5}}`)
3. Add new variables if needed
4. Apply theme to regenerate: `wallust theme <theme-name>`

### Example: Customizing Hyprland Border Colors

**File:** `config/wallust/templates/hyprland-colors.conf`

```conf
$color_active   = rgb({{color12 | remove: "#"}})
$color_inactive = rgb({{color8 | remove: "#"}})
$color_group    = rgb({{color6 | remove: "#"}})
$color_urgent   = rgb({{color9 | remove: "#"}})

general {
    col.active_border = $color_active
    col.inactive_border = $color_inactive
}

group {
    col.border_active = $color_group
    col.border_inactive = $color_inactive
    col.border_locked_active = $color_urgent
}
```

**Customization ideas:**
- Change `color12` to `color4` for less bright active borders
- Use `color5` (magenta) instead of `color6` (cyan) for groups
- Add gradient borders: `col.active_border = $color_active $color_group 45deg`

## Creating Custom Themes

### Method 1: Using wallust.toml Custom Themes

**File:** `~/nixos-dotfiles/config/wallust/wallust.toml`

Add custom color schemes:

```toml
[custom_themes]
my-custom-theme = {
    color0 = "#1a1b26",
    color1 = "#f7768e",
    color2 = "#9ece6a",
    color3 = "#e0af68",
    color4 = "#7aa2f7",
    color5 = "#bb9af7",
    color6 = "#7dcfff",
    color7 = "#a9b1d6",
    color8 = "#414868",
    color9 = "#f7768e",
    color10 = "#9ece6a",
    color11 = "#e0af68",
    color12 = "#7aa2f7",
    color13 = "#bb9af7",
    color14 = "#7dcfff",
    color15 = "#c0caf5",
}
```

**Apply custom theme:**
```bash
wallust theme my-custom-theme
```

### Method 2: Generate from Image

Wallust can extract colors from any image:

```bash
wallust run ~/Pictures/Wallpapers/my-wallpaper.jpg
```

This automatically:
1. Extracts 16-color palette from image
2. Generates all template files
3. Applies theme to all applications

### Method 3: JSON Theme Files

Create a JSON file with your theme:

**File:** `~/.config/wallust/my-theme.json`

```json
{
  "name": "My Custom Theme",
  "colors": {
    "background": "#1a1b26",
    "foreground": "#c0caf5",
    "color0": "#1a1b26",
    "color1": "#f7768e",
    "color2": "#9ece6a",
    "color3": "#e0af68",
    "color4": "#7aa2f7",
    "color5": "#bb9af7",
    "color6": "#7dcfff",
    "color7": "#a9b1d6",
    "color8": "#414868",
    "color9": "#f7768e",
    "color10": "#9ece6a",
    "color11": "#e0af68",
    "color12": "#7aa2f7",
    "color13": "#bb9af7",
    "color14": "#7dcfff",
    "color15": "#c0caf5"
  }
}
```

**Apply:**
```bash
wallust --config-file ~/.config/wallust/my-theme.json
```

## Advanced: Adding New Applications to Theming

### Step 1: Create Template

Create a new template file in `config/wallust/templates/`:

**Example:** `config/wallust/templates/kitty-colors.conf`

```conf
background {{background}}
foreground {{foreground}}
cursor {{cursor}}

color0 {{color0}}
color8 {{color8}}

color1 {{color1}}
color9 {{color9}}

color2 {{color2}}
color10 {{color10}}

color3 {{color3}}
color11 {{color11}}

color4 {{color4}}
color12 {{color12}}

color5 {{color5}}
color13 {{color13}}

color6 {{color6}}
color14 {{color14}}

color7 {{color7}}
color15 {{color15}}
```

### Step 2: Configure Output in wallust.toml

Edit `config/wallust/wallust.toml`:

```toml
[templates]
kitty = { template = "kitty-colors.conf", target = "~/.config/kitty/colors-wallust.conf" }
```

### Step 3: Import in Application Config

Edit your kitty config:

**File:** `~/.config/kitty/kitty.conf`

```conf
include colors-wallust.conf
```

### Step 4: Add Reload to theme-picker.sh

Edit `config/hypr/scripts/theme-picker.sh`:

```bash
sleep 0.2
pkill -SIGUSR2 waybar
hyprctl reload
makoctl reload
pkill -USR1 kitty
```

### Step 5: Add to NixOS Config (if needed)

Edit `home.nix`:

```nix
configs = {
  kitty = "kitty";
};
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake .#nixos-gmc
```

## Testing Theme Changes

### Quick Test (No Rebuild)

```bash
vim ~/nixos-dotfiles/config/wallust/templates/rofi-colors.rasi
wallust theme Tokyo-Night
rofi -show drun
```

### Full System Test

Run theme picker and check all applications:
- Hyprland borders (focus different windows)
- Alacritty (open terminal)
- Waybar (check status bar)
- Rofi (mainMod + R)
- Mako (test notification: `notify-send "Test" "Message"`)

### Debugging Template Issues

```bash
wallust theme Tokyo-Night 2>&1 | tee /tmp/wallust-debug.log
cat ~/.config/rofi/colors-wallust.rasi
cat ~/.config/hypr/themes/colors-wallust.conf
journalctl --user -u waybar -f
```

## Common Customization Scenarios

### Change Rofi Accent Color from Blue to Purple

**File:** `config/wallust/templates/rofi-colors.rasi`

```rasi
accent: {{color5}};  /* Changed from {{color4}} */
```

### Make Hyprland Borders More Vibrant

**File:** `config/wallust/templates/hyprland-colors.conf`

```conf
$color_active   = rgb({{color12 | remove: "#"}})  /* Instead of color4 */
$color_inactive = rgb({{color8 | remove: "#"}})
```

### Add Semi-Transparent Waybar Background

**File:** `config/wallust/templates/waybar-colors.css`

```css
@define-color wallust_bg_alpha rgba(..., 0.92);

window#waybar {
    background-color: @wallust_bg_alpha;
}
```

## Tips and Best Practices

1. **Always test templates before committing**
   - Apply theme after editing
   - Check all affected applications

2. **Use semantic color variables**
   - Define meaningful names (`accent`, `border-color`, `selected`)
   - Don't use raw `{{colorN}}` in app configs

3. **Keep backups of working configs**
   - Git commit before major template changes
   - Document your customizations

4. **Consider contrast ratios**
   - Ensure text is readable on backgrounds
   - Test with both dark and light themes

5. **NixOS workflow**
   - Template changes don't require rebuild
   - Only rebuild when changing `wallust.toml` structure
   - Generated files (`colors-wallust.*`) are gitignored

## Troubleshooting

### Theme doesn't apply to application

1. Check template exists: `ls ~/.config/wallust/templates/`
2. Check output generated: `ls ~/.config/<app>/colors-wallust.*`
3. Check application imports it: `grep wallust ~/.config/<app>/*`
4. Check application reloads: Add reload command to `theme-picker.sh`

### Colors look wrong

1. Verify template syntax: Check for typos in `{{colorN}}`
2. Check color mapping: `cat ~/.config/<app>/colors-wallust.*`
3. Test with different theme: Some themes may have unusual palettes
4. Check wallust version: `wallust --version` (should be v3.x)

### Template not regenerating

1. Check wallust.toml config: `cat ~/.config/wallust/wallust.toml`
2. Verify template path correct
3. Run wallust manually: `wallust theme <theme-name> -v`
4. Check permissions: `ls -la ~/.config/<app>/`

## References

- **Wallust Documentation:** https://explosion-mental.codeberg.page/wallust/v3.html
- **Wallust GitHub:** https://github.com/explosion-mental/wallust
- **Hyprland Wiki:** https://wiki.hyprland.org/
