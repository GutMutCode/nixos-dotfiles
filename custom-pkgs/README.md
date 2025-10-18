# Custom Packages - Local Development Space

## Purpose

This directory serves as a **local development and experimentation space** for custom Nix packages before they are migrated to dedicated GitHub repositories.

## Workflow

### 1. Development (Here)
- Create new package in subdirectory
- Add to `overlay.nix`
- Test locally with `nixos-rebuild test`

### 2. Testing
- Quick iteration without git commits
- Immediate integration testing
- Debug and refine

### 3. Migration (When Stable)
- Create GitHub repository
- Move to production (see examples below)
- Remove from this directory

## Current Structure

```
custom-pkgs/
├── README.md      # This file
└── overlay.nix    # Empty template for experimental packages
```

## Migrated Packages

Packages that started here and moved to GitHub:

- **factory-cli** → [factory-cli-nix](https://github.com/GutMutCode/factory-cli-nix)
- **claude-code-npm** → [claude-code-npm](https://github.com/GutMutCode/claude-code-npm)
- **opencode** → [opencode-nix](https://github.com/GutMutCode/opencode-nix)

## Quick Start

### Create New Package

```bash
# 1. Create package directory
mkdir -p custom-pkgs/my-tool

# 2. Create package definition
cat > custom-pkgs/my-tool/default.nix <<'EOF'
{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "my-tool";
  version = "1.0.0";

  src = fetchurl {
    url = "https://example.com/my-tool-${version}.tar.gz";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  meta = with lib; {
    description = "My custom tool";
    homepage = "https://example.com";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
EOF

# 3. Add to overlay.nix
cat > custom-pkgs/overlay.nix <<'EOF'
final: prev: {
  my-tool = prev.callPackage ./my-tool { };
}
EOF

# 4. Test build
nix build --impure --expr '(builtins.getFlake (toString ./.)).nixosConfigurations.nixos-gmc.pkgs.my-tool'

# 5. Test in system
sudo nixos-rebuild test --flake .#nixos-gmc
```

## When to Migrate to GitHub

Migrate when the package is:
- ✅ **Stable** - works reliably
- ✅ **Tested** - verified on target system
- ✅ **Documented** - has clear description
- ✅ **Versioned** - uses explicit version numbers
- ✅ **Reusable** - useful on other machines

## Related Documentation

- **[docs/custom-package-workflow.md](../docs/custom-package-workflow.md)** - Complete workflow guide
- **[docs/custom-package-troubleshooting.md](../docs/custom-package-troubleshooting.md)** - Binary packaging issues
- **[docs/unfree-package-management.md](../docs/unfree-package-management.md)** - Managing unfree packages

## Examples

See migrated repositories for production-ready examples:
- [factory-cli-nix](https://github.com/GutMutCode/factory-cli-nix) - CLI tool example
- [claude-code-npm](https://github.com/GutMutCode/claude-code-npm) - npm package example
- [opencode-nix](https://github.com/GutMutCode/opencode-nix) - Binary package example
