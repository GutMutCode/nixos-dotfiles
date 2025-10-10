# NixOS Dotfiles

Personal NixOS configuration with Hyprland, home-manager, and modular architecture.

## Structure

```
.
├── flake.nix              # Flake entry point
├── configuration.nix      # System configuration (imports modules)
├── home.nix              # Home-manager configuration (imports modules)
├── hardware-configuration.nix
├── modules/
│   ├── hardware/         # Hardware-specific configs (nvidia, bluetooth, audio)
│   ├── services/         # System services (ssh, tor)
│   ├── desktop/          # Desktop environment (hyprland, fonts, i18n)
│   ├── home/            # Home-manager modules (packages, programs, services)
│   ├── system.nix       # Core system settings
│   └── secrets.nix      # sops-nix integration
├── config/              # Application configs (hypr, waybar, nvim, etc.)
├── custom-pkgs/         # Custom package overlays
└── secrets/             # Encrypted secrets (sops-nix)
```

## Quick Start

```bash
# Build and apply configuration
sudo nixos-rebuild switch --flake .#nixos-gmc

# Test without applying
sudo nixos-rebuild test --flake .#nixos-gmc

# Check flake validity
nix flake check

# Format Nix files
nixpkgs-fmt <file>
```

## Key Features

- **Flake-based**: Reproducible builds with pinned dependencies
- **Modular**: Organized by feature (hardware, services, desktop, home)
- **Stable + Unstable**: nixpkgs 25.05 with unstable overlay
- **Home-manager**: User environment managed declaratively
- **sops-nix**: Encrypted secret management
- **Hyprland**: Wayland compositor with dynamic theming (wallust)
- **Symlinked configs**: `~/.config` → `~/nixos-dotfiles/config`

## Documentation

- **[CLAUDE.md](CLAUDE.md)** - Development guidelines for AI assistants
- **[docs/secrets.md](docs/secrets.md)** - Secrets management with sops-nix
- **[docs/theming.md](docs/theming.md)** - Wallust theming customization
- **[docs/obs-studio.md](docs/obs-studio.md)** - OBS Studio configuration

## Architecture

### Nixpkgs Channels
- **Stable (25.05)**: System packages, core services
- **Unstable**: Latest tools (claude-code, opencode, amp-cli)

### Module Organization
- **System modules** (`modules/hardware/`, `modules/services/`, `modules/desktop/`)
  - Imported by `configuration.nix`
  - Applied at system level
  
- **Home modules** (`modules/home/`)
  - Imported by `home.nix`
  - Applied per-user via home-manager

### Suckless Development
```bash
# Enter development shell
nix develop .#suckless

# Build custom suckless tools
cd config/{dwm,st,dmenu,dwl,slstatus}
make
```

## Customization

### Adding Packages
- **System packages**: `modules/system.nix`
- **User packages**: `modules/home/packages.nix`
- **Unfree packages**: `modules/home/unfree.nix`

### Modifying Services
- **System services**: `modules/services/*.nix`
- **User services**: `modules/home/services.nix`

### Desktop Environment
- **Hyprland config**: `config/hypr/`
- **Waybar config**: `config/waybar/`
- **Theme**: `config/wallust/`

## State Version

This configuration uses NixOS 25.05. Do not change `system.stateVersion` unless migrating data.
