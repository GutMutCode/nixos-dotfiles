# NixOS Dotfiles - Agent Guidelines

## Build/Lint/Test Commands
- Build NixOS configuration: `sudo nixos-rebuild switch --flake .#nixos-gmc`
- Check Nix code: `nix flake check`
- Format Nix files: `nixpkgs-fmt <file>`
- Lint Nix: `nil diagnostics <file>`
- For Suckless development: Use the `nix develop .#suckless` shell

## Code Style Guidelines
- **Nix**: Follow the nixpkgs formatting conventions
- **Imports**: Group imports by type (standard lib, then custom modules)
- **Naming**: Use camelCase for variables, snake_case for functions
- **Comments**: Add comments for complex expressions or non-obvious configurations
- **Error Handling**: Use `lib.mkIf` and `lib.mkMerge` for conditional configuration
- **Types**: Use appropriate Nix expression types (lists, attrs, etc.)
- **Formatting**: Use 2-space indentation in Nix files
- **Structure**: Keep related configurations in appropriate modules

## Repository Organization
- `/config/` - Configuration files for various tools/WMs
- `/modules/` - NixOS module definitions
- Root files - Main NixOS configuration files