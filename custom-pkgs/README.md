# Custom Packages - Local Development Space

Local experimentation space for custom Nix packages before GitHub migration.

## Quick Start

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
echo 'final: prev: { my-tool = prev.callPackage ./my-tool { }; }' > custom-pkgs/overlay.nix

# 4. Test build
nix build --impure --expr '(builtins.getFlake (toString ./.)).nixosConfigurations.nixos-gmc.pkgs.my-tool'

# 5. Test in system (requires sudo)
sudo nixos-rebuild test --flake .#nixos-gmc
```

## Workflow

1. **Develop** - Create package here, add to overlay.nix
2. **Test** - Quick iteration without commits
3. **Migrate** - When stable, move to GitHub (see workflow guide)

## Migrated Packages

- [factory-cli-nix](https://github.com/GutMutCode/factory-cli-nix)
- [claude-code-npm](https://github.com/GutMutCode/claude-code-npm)
- [opencode-nix](https://github.com/GutMutCode/opencode-nix)

## Documentation

- **[Complete Workflow Guide](../docs/custom-package-workflow.md)** - Detailed process
- **[Troubleshooting](../docs/custom-package-troubleshooting.md)** - Binary packaging issues
- **[Unfree Management](../docs/unfree-package-management.md)** - Managing unfree packages
