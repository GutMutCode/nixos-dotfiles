# Custom Package Management Workflow

## Overview

This NixOS configuration uses a **hybrid approach** for managing custom packages:
- **custom-pkgs/**: Local development and experimentation space
- **GitHub repositories**: Stable, versioned packages for production use

## Workflow

### 1. Initial Development (Local)

When creating a new custom package, start in `custom-pkgs/`:

```bash
# Create package directory
mkdir -p custom-pkgs/my-package

# Create package definition
cat > custom-pkgs/my-package/default.nix <<EOF
{ lib, stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "my-package";
  version = "1.0.0";
  # ... package definition
}
EOF
```

**Add to overlay** (`custom-pkgs/overlay.nix`):
```nix
final: prev: {
  my-package = prev.callPackage ./my-package { };
}
```

**Enable in flake.nix**:
```nix
overlaysList = [
  factory-cli-nix.overlays.default
  claude-code-npm.overlays.default
  opencode-nix.overlays.default
  (import ./custom-pkgs/overlay.nix)  # Add local overlay
];
```

### 2. Local Testing

```bash
# Quick test build
nix build --impure --expr '(builtins.getFlake (toString ./.)).nixosConfigurations.nixos-gmc.pkgs.my-package'

# Test in system
sudo nixos-rebuild test --flake .#nixos-gmc

# Verify
./result/bin/my-package --version
```

**Advantages**:
- No git commit/push needed
- Fast iteration cycle
- Immediate integration testing

### 3. Stabilization and GitHub Migration

When the package is stable and ready for production:

#### Step 1: Create GitHub Repository

```bash
# Create repository structure
mkdir -p /tmp/my-package-nix
cd /tmp/my-package-nix

# Copy package definition
cp ~/nixos-dotfiles/custom-pkgs/my-package/default.nix ./package.nix

# Create flake.nix (follow pattern from claude-code-npm or opencode-nix)
```

**Minimal flake.nix template**:
```nix
{
  description = "My Package for NixOS and Nix users";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      overlays.default = import ./overlay.nix;
      nixosModules.default = import ./module.nix;
      homeManagerModules.default = import ./module.nix;

      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        {
          my-package = pkgs.my-package;
          default = pkgs.my-package;
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.my-package}/bin/my-package";
        };
      });
    };
}
```

**overlay.nix**:
```nix
final: prev: {
  my-package = prev.callPackage ./package.nix { };
}
```

**module.nix**:
```nix
{ config, lib, pkgs, ... }:

{
  config = {
    nixpkgs.overlays = [ (import ./overlay.nix) ];
  };
}
```

#### Step 2: Create and Push Repository

```bash
cd /tmp/my-package-nix

# Initialize git
git init
git add .
git commit -m "Initial commit: My Package v1.0.0"

# Create GitHub repository and push
git remote add origin git@github.com:GutMutCode/my-package-nix.git
git push -u origin master
```

#### Step 3: Update nixos-dotfiles

The flake.nix uses **DRY (Don't Repeat Yourself)** abstraction. You only need to add your package in **3 places**:

**1. Add to flake.nix inputs** (lines 17-33):
```nix
inputs = {
  # Core dependencies
  # ...

  # Custom packages from GitHub
  # When adding new package:
  # 1. Add input here
  # 2. Add to outputs parameters
  # 3. Add to customPackageInputs list in outputs
  factory-cli-nix = { ... };
  claude-code-npm = { ... };
  opencode-nix = { ... };
  my-package-nix = {  # ADD HERE
    url = "github:GutMutCode/my-package-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

**2. Add to outputs parameters** (line 36):
```nix
outputs = { self, nixpkgs, ..., my-package-nix, ... }:  # ADD HERE
```

**3. Add to customPackageInputs list** (lines 40-44):
```nix
customPackageInputs = [
  factory-cli-nix
  claude-code-npm
  opencode-nix
  my-package-nix  # ADD HERE
];
```

**That's it!** The following are automatically handled:
- ✅ Overlays: `map (pkg: pkg.overlays.default) customPackageInputs`
- ✅ Home-manager modules: `map (pkg: pkg.homeManagerModules.default) customPackageInputs`

No need to manually add to overlaysList or sharedModules.

**Update flake.lock**:
```bash
nix flake update
```

**Remove from custom-pkgs**:
```bash
rm -rf custom-pkgs/my-package
# Remove from custom-pkgs/overlay.nix
```

#### Step 4: Test GitHub Integration

```bash
# Test configuration
nix flake check

# Test build from GitHub
nix build --impure --expr '(builtins.getFlake (toString ./.)).nixosConfigurations.nixos-gmc.pkgs.my-package'

# Verify version
./result/bin/my-package --version
```

### 4. Maintenance

**For updates**:

```bash
# Update in GitHub repository
cd /path/to/my-package-nix
# Make changes to package.nix
git commit -am "Update to v1.1.0"
git push

# Update in nixos-dotfiles
cd ~/nixos-dotfiles
nix flake update my-package-nix
sudo nixos-rebuild switch --flake .#nixos-gmc
```

## Decision Matrix

### Use custom-pkgs/ when:
- 🧪 **Experimenting** with new package
- ⚡ **Rapid iteration** needed
- 🔒 **Not ready** for public use
- 🚧 **Unstable** or frequently changing
- 📝 **Temporary** workaround/patch

### Use GitHub repository when:
- ✅ **Stable** and tested
- 🔄 **Reusable** across machines
- 📦 **Version control** needed
- 🌐 **Shareable** with others
- 🏗️ **Production** use

## Example Timeline

**Week 1-2**: Develop in custom-pkgs/
- Create package definition
- Test locally
- Fix bugs and iterate quickly

**Week 3**: Stabilization
- Package works reliably
- Version pinned
- Documentation written

**Week 4**: GitHub migration
- Create repository
- Add to flake inputs
- Remove from custom-pkgs/

**Ongoing**: Maintenance via GitHub
- Version updates via git tags
- Flake updates pull new versions

## Current State

### Local (custom-pkgs/)
```
custom-pkgs/
└── overlay.nix  # Empty or experimental packages only
```

### GitHub Repositories
- ✅ factory-cli-nix (v0.1.5)
- ✅ claude-code-npm (v2.0.22)
- ✅ opencode-nix (v0.15.7)

## Cleanup Checklist

When migrating a package from custom-pkgs/ to GitHub:

- [ ] Package builds successfully
- [ ] Tests pass
- [ ] Documentation written
- [ ] GitHub repository created
- [ ] Flake.nix properly structured
- [ ] Added to nixos-dotfiles/flake.nix inputs
- [ ] Added to overlaysList
- [ ] Added to sharedModules (if needed)
- [ ] `nix flake update` executed
- [ ] `nix flake check` passes
- [ ] Removed from custom-pkgs/
- [ ] Updated custom-pkgs/overlay.nix

## Best Practices

### 1. Version Pinning
Always use explicit versions in package definitions:
```nix
version = "1.0.0";  # Good
version = "latest"; # Bad
```

### 2. Unfree Packages
Add unfree packages to whitelist during development:
```nix
# In flake.nix unstablePkgs or home-manager
allowedUnfreePackages ++ [
  "my-package"
]
```

### 3. Binary Packages
For pre-built binaries (like Bun/Deno), reference troubleshooting docs:
- See `docs/custom-package-troubleshooting.md` for autoPatchelfHook issues

### 4. Testing
Always test both local and GitHub versions:
```bash
# Local
nix build --impure --expr '...'

# GitHub (after migration)
nix build github:GutMutCode/my-package-nix
```

### 5. Git Hygiene
Keep package development separate from dotfiles:
```bash
# Don't commit work-in-progress packages to nixos-dotfiles
git add custom-pkgs/stable-package/  # Only stable ones
```

## Troubleshooting

### Package not found after GitHub migration
```bash
# Check flake inputs
nix flake metadata

# Update flake.lock
nix flake update my-package-nix

# Verify overlay
nix flake show
```

### Local changes not reflected
```bash
# Custom-pkgs changes require rebuild
sudo nixos-rebuild test --flake .#nixos-gmc

# GitHub changes require flake update
nix flake update
```

### Unfree package blocked
```bash
# Check package name
nix eval nixpkgs#my-package.pname

# Add to allowedUnfreePackages in flake.nix
```

## Related Documentation

- **docs/unfree-package-management.md**: Managing unfree packages
- **docs/custom-package-troubleshooting.md**: Binary packaging issues
- **tests/factory-cli-nix/**: Example GitHub repository structure
- **tests/claude-code-npm/**: npm package example
- **tests/opencode-nix/**: Binary package example

---

**Last Updated**: 2025-10-18
**Workflow**: Hybrid (local development → GitHub production)
