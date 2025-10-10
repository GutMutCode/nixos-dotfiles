# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### NixOS System Management
- **Build and apply configuration**: `sudo nixos-rebuild switch --flake .#nixos-gmc`
- **Test configuration without applying**: `sudo nixos-rebuild test --flake .#nixos-gmc`
- **Build configuration only**: `nix build .#nixosConfigurations.nixos-gmc.config.system.build.toplevel`
- **Check flake validity**: `nix flake check`
- **Update flake inputs**: `nix flake update`

### Code Quality and Formatting
- **Format Nix files**: `nixpkgs-fmt <file>`
- **Nix language server diagnostics**: `nil diagnostics <file>`
- **Check Nix syntax**: `nix-instantiate --parse <file>`

### Suckless Development Environment
- **Enter suckless development shell**: `nix develop .#suckless`
- **Build suckless programs**: Use `make` within the development shell in `/config/dmenu`, `/config/dwm`, `/config/st`, `/config/dwl`, or `/config/slstatus`

## Code Architecture

### Flake Structure
This is a NixOS flake-based configuration with the following key components:

- **`flake.nix`**: Main entry point defining inputs (nixpkgs, home-manager) and outputs (nixosConfigurations, devShells)
- **`configuration.nix`**: System-wide NixOS configuration (boot, networking, services, users)
- **`home.nix`**: User-specific configuration managed by home-manager
- **`hardware-configuration.nix`**: Hardware-specific settings (auto-generated)

### Module Organization
- **`/modules/suckless.nix`**: Custom overrides for suckless tools (st, dmenu) using local source code
- **`/config/`**: Configuration files and custom builds for various tools:
  - Window managers: `dwm/`, `dwl/`, `qtile/`
  - Terminal: `st/`, `alacritty/`
  - Utilities: `dmenu/`, `rofi/`, `slstatus/`
  - Editor: `nvim/`

### Key Architectural Patterns
- **Flake inputs**: Uses stable nixpkgs (25.05) with unstable overlay capability
- **Home-manager integration**: User packages and configurations managed declaratively
- **Suckless philosophy**: Custom builds of minimal tools (dwm, st, dmenu) with local patches
- **Symlinked configs**: XDG config files symlinked from repository using `config.lib.file.mkOutOfStoreSymlink`
- **Modular design**: Separate modules for different functionality areas

### Development Workflow
1. **Suckless tools**: Modify source in `/config/[tool]/`, build with `make` in devShell
2. **NixOS changes**: Edit `.nix` files, test with `nixos-rebuild test`, apply with `switch`
3. **Home-manager changes**: Modify `home.nix`, rebuild system to apply user config changes
4. **Config files**: Edit files in `/config/`, changes automatically reflected via symlinks

### Special Considerations
- Suckless tools require compilation in dedicated development environment
- System requires rebuild for NixOS configuration changes
- User configuration changes applied through home-manager module
- Custom font packages and unfree software explicitly allowlisted
- ~/.config 폴더는 ~/nixos-dotfiles/config 의 symlink 이다.
- sudo 명령어는 수동으로 진행.
- 모든 코드와 주석은 LLM이 parsing하기 쉬운 형태로 작성해야해.
- 작업을 진행할땐 항상 우선순위 대로 진행해야해.