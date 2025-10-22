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
│   ├── services/         # System services (ssh, tor, home-server)
│   ├── desktop/          # Desktop environment (hyprland, fonts, i18n)
│   ├── home/            # Home-manager modules (packages, programs, services, xdg)
│   ├── system.nix       # Core system settings
│   └── secrets.nix      # sops-nix integration
├── config/              # Application configs (symlinked to ~/.config via xdg.nix)
│   ├── hypr/            # Hyprland compositor
│   ├── waybar/          # Status bar
│   ├── nvim/            # Neovim editor
│   ├── rofi/            # Application launcher
│   ├── mako/            # Notification daemon
│   ├── wallust/         # Dynamic theming
│   ├── fcitx5/          # Input method
│   └── wallpapers/      # Wallpaper collection
├── docker/              # Home server configurations (symlinked to /srv/docker)
│   ├── traefik/         # Reverse proxy & SSL
│   ├── nextcloud/       # Cloud storage
│   ├── jellyfin/        # Media server
│   ├── portainer/       # Container management
│   └── ...              # Additional services
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
- **Symlinked configs**: Managed via `modules/home/xdg.nix` using `mkOutOfStoreSymlink`

## Documentation

- **[CLAUDE.md](CLAUDE.md)** - Development guidelines for AI assistants
- **[docs/secrets.md](docs/secrets.md)** - Secrets management with sops-nix
- **[docs/theming.md](docs/theming.md)** - Wallust theming customization
- **[docs/obs-studio.md](docs/obs-studio.md)** - OBS Studio configuration
- **[docker/README.md](docker/README.md)** - All-in-one home server setup with Docker & Traefik
- **[docker/TROUBLESHOOTING.md](docker/TROUBLESHOOTING.md)** - Common issues and solutions for home server

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
Configuration files are symlinked from `~/nixos-dotfiles/config/` to `~/.config/` via `modules/home/xdg.nix`:

- **Hyprland**: `config/hypr/` → `~/.config/hypr/`
- **Waybar**: `config/waybar/` → `~/.config/waybar/`
- **Wallust**: `config/wallust/` → `~/.config/wallust/`
- **Rofi**: `config/rofi/` → `~/.config/rofi/`
- **Neovim**: `config/nvim/` → `~/.config/nvim/`
- **Mako**: `config/mako/` → `~/.config/mako/`
- **Fcitx5**: `config/fcitx5/` → `~/.config/fcitx5/`
- **Wallpapers**: `config/wallpapers/` → `~/Pictures/wallpapers/`

**Changes are applied immediately** (no rebuild required) since these are symlinks pointing to the repository.

## State Version

This configuration uses NixOS 25.05. Do not change `system.stateVersion` unless migrating data.
