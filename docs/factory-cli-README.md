# factory-cli-nix

Factory AI CLI (droid) for NixOS and Nix users.

## Quick Start

```nix
# flake.nix
{
  inputs.factory-cli-nix.url = "github:yourusername/factory-cli-nix";

  outputs = { factory-cli-nix, ... }: {
    homeConfigurations.user = {
      modules = [
        factory-cli-nix.homeManagerModules.default
        { services.factory-cli.enable = true; }
      ];
    };
  };
}
```

```bash
# Then rebuild and run
droid
```

## Installation Methods

### Method 1: Flake Input (Recommended)

**For home-manager:**
```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    factory-cli-nix.url = "github:yourusername/factory-cli-nix";
  };

  outputs = { nixpkgs, home-manager, factory-cli-nix, ... }: {
    homeConfigurations."user@hostname" = home-manager.lib.homeManagerConfiguration {
      modules = [
        factory-cli-nix.homeManagerModules.default
        {
          services.factory-cli.enable = true;
        }
      ];
    };
  };
}
```

**For NixOS:**
```nix
{
  inputs.factory-cli-nix.url = "github:yourusername/factory-cli-nix";

  outputs = { factory-cli-nix, ... }: {
    nixosConfigurations.hostname = {
      modules = [
        factory-cli-nix.nixosModules.default
        {
          services.factory-cli.enable = true;
        }
      ];
    };
  };
}
```

### Method 2: Overlay Only

```nix
{
  inputs.factory-cli-nix.url = "github:yourusername/factory-cli-nix";

  nixpkgs.overlays = [ factory-cli-nix.overlays.default ];

  home.packages = [ pkgs.factory-cli ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "factory-cli" "steam-unwrapped" ];
}
```

### Method 3: Direct Install

```bash
# Temporary shell
nix shell github:yourusername/factory-cli-nix

# Install to profile
nix profile install github:yourusername/factory-cli-nix

# Run directly
nix run github:yourusername/factory-cli-nix
```

## Configuration

### Available Options

```nix
{
  services.factory-cli = {
    # Enable Factory CLI installation
    enable = true;  # default: false

    # Custom package (for testing or overrides)
    package = pkgs.factory-cli;  # default: pkgs.factory-cli
  };
}
```

## Platform Support

| Platform      | Status | Notes                          |
|---------------|--------|--------------------------------|
| x86_64-linux  | ✅     | Uses steam-run FHS wrapper     |
| aarch64-linux | ✅     | Uses steam-run FHS wrapper     |
| x86_64-darwin | ✅     | Native binary                  |
| aarch64-darwin| ✅     | Native binary                  |

## Requirements

### Linux
- `xdg-utils` (automatically included)
- Unfree packages enabled (automatically configured by module)

### macOS
- No additional requirements

## Usage

```bash
# Start droid in your project
cd /path/to/your/project
droid

# Check version
droid --version
```

## Troubleshooting

### "Bun help" instead of Factory AI UI

**Problem**: Running `droid` shows Bun help instead of Factory AI interface.

**Solutions**:
1. Ensure you're using the module or have unfree packages enabled
2. Check that steam-run is available (Linux)
3. Rebuild your configuration

### Binary shows wrong version

**Problem**: `droid --version` shows unexpected version.

**Solution**: Clear Nix store cache and rebuild:
```bash
nix-store --delete /nix/store/*-factory-cli-*
# Then rebuild your configuration
```

### "Raw mode is not supported" error

**Normal behavior** when testing with piped stdin. Run `droid` normally in an interactive terminal.

## Development

```bash
# Clone repository
git clone https://github.com/yourusername/factory-cli-nix
cd factory-cli-nix

# Test build
nix build

# Test run
nix run . -- --version

# Enter development shell
nix develop
```

## Version Updates

This package tracks Factory AI CLI releases. To update:

```bash
# Update version in overlay.nix
# Update SHA256 hashes
nix-prefetch-url https://downloads.factory.ai/factory-cli/releases/VERSION/PLATFORM/ARCH/droid
nix hash convert --hash-algo sha256 <hash>

# Test build
nix build
```

## License

- **This repository (Nix packaging)**: MIT License
- **Factory CLI**: Proprietary/Unfree - requires Factory AI account

Factory CLI is proprietary software by Factory AI. This repository only provides Nix packaging.

## Contributing

Contributions welcome! Please:
1. Test on your platform
2. Update version in both overlay.nix and README
3. Verify SHA256 hashes
4. Run `nix flake check`

## Credits

- Factory AI for the excellent CLI tool
- NixOS community for packaging guidance

## Links

- [Factory AI Documentation](https://docs.factory.ai/)
- [Factory CLI Quickstart](https://docs.factory.ai/cli/getting-started/quickstart)
- [NixOS Wiki](https://nixos.wiki/)
