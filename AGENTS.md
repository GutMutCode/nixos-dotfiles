# NixOS Dotfiles - Agent Guidelines

## Build/Test Commands
- **Build system**: `sudo nixos-rebuild switch --flake .#nixos-gmc`
- **Test without applying**: `sudo nixos-rebuild test --flake .#nixos-gmc`
- **Check flake**: `nix flake check`
- **Format Nix files**: `nixpkgs-fmt <file>` (run on modified .nix files)
- **Lint Nix**: `nil diagnostics <file>`
- **Suckless dev**: Enter `nix develop .#suckless`, then `make` in config/{dwm,st,dmenu,dwl,slstatus}

## Code Style
- **Language**: Pure Nix (declarative configuration language)
- **Formatting**: 2-space indentation, use `nixpkgs-fmt` for consistency
- **Imports**: Group by type (hardware, modules, then services)
- **Naming**: camelCase for Nix variables, snake_case for custom functions, kebab-case for package names
- **Comments**: Minimal; add only for non-obvious configurations or security settings
- **Structure**: Keep modules in `/modules/`, configs in `/config/`, root files for main system config
- **Error handling**: Use `lib.mkIf`, `lib.mkDefault`, `lib.mkForce` for conditional/override logic
- **Types**: Leverage Nix types (attrs, lists, strings); avoid free-form when structured types exist
- **Symlinks**: Use `config.lib.file.mkOutOfStoreSymlink` for XDG config files (see home.nix)
- **Unfree packages**: Add to allowUnfreePredicate list in flake.nix or home.nix

## Architecture Notes
- Flake-based NixOS config with home-manager integration
- Stable (25.05) + unstable overlay pattern for bleeding-edge tools
- Local suckless builds via config/ directory and dedicated devShell
