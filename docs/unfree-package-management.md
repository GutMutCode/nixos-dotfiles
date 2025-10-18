# Unfree Package Management Analysis

## Overview

This NixOS configuration uses a **whitelist-based approach** for managing unfree packages, providing fine-grained control over which proprietary software is allowed on the system.

## Architecture

### 1. Core Components (flake.nix)

```nix
# Lines 29-44: Master whitelist (system-wide unfree packages)
# System-wide unfree packages: hardware drivers and common applications
allowedUnfreePackages = [
  # Hardware drivers
  "nvidia-x11"
  "nvidia-settings"
  # Communication
  "discord"
  "slack"
  # Media
  "spotify"
  # Gaming
  "steam"
  "steam-unwrapped"
  "steam-original"
  "steam-run"
];

# Lines 46-48: CUDA package auto-detection
isCudaPackage = pkg:
  let name = nixpkgs.lib.getName pkg;
  in builtins.match "^(cuda_.*|libcu.*|libnv.*|cudnn.*)" name != null;
```

### 2. Application Points

The unfree policy is applied at **four different levels**:

#### Level 1: Stable Packages (pkgs)
```nix
# Lines 50-55
pkgs = import nixpkgs {
  inherit system;
  overlays = overlaysList;
  config.allowUnfreePredicate = pkg:
    builtins.elem (nixpkgs.lib.getName pkg) allowedUnfreePackages || isCudaPackage pkg;
};
```
**Scope**: Base system packages from stable nixpkgs
**Allowed**: Master whitelist + CUDA packages

#### Level 2: Unstable Packages (unstablePkgs)
```nix
# Lines 57-73
unstablePkgs = import nixpkgs-unstable {
  inherit system;
  overlays = overlaysList;
  config.allowUnfreePredicate = pkg:
    builtins.elem (nixpkgs.lib.getName pkg) (allowedUnfreePackages ++ [
      # Development/AI tools
      "factory-cli"
      "claude-code-npm"
      "claude-code"
      "opencode"
      "codex"
      "amp-cli"
      # Creative tools
      "blender"
      "davinci-resolve"
    ]) || isCudaPackage pkg;
};
```
**Scope**: Development and cutting-edge packages from unstable
**Allowed**: Master whitelist + development/creative tools + CUDA packages

#### Level 3: NixOS System Configuration
```nix
# Lines 102-103
nixpkgs.config.allowUnfreePredicate = pkg:
  builtins.elem (nixpkgs.lib.getName pkg) allowedUnfreePackages || isCudaPackage pkg;
```
**Scope**: System-level packages
**Allowed**: Master whitelist + CUDA packages

#### Level 4: Home-Manager User Configuration
```nix
# Lines 117-130
nixpkgs.config.allowUnfreePredicate = pkg:
  builtins.elem (nixpkgs.lib.getName pkg) (allowedUnfreePackages ++ [
    # Development/AI tools
    "factory-cli"
    "claude-code-npm"
    "claude-code"
    "opencode"
    "codex"
    "amp-cli"
    # Creative tools
    "blender"
    "davinci-resolve"
  ]) || isCudaPackage pkg;
```
**Scope**: User-specific packages
**Allowed**: Master whitelist + development/creative tools + CUDA packages

## Package Categories

### System-Wide Unfree Packages (Master Whitelist)
Essential system drivers and common applications:
- **Hardware Drivers**: nvidia-x11, nvidia-settings
- **Communication**: discord, slack
- **Media**: spotify
- **Gaming**: steam, steam-unwrapped, steam-original, steam-run

### User/Development Additional Packages
Development and creative tools (user-level only):
- **AI/Development Tools**: factory-cli, claude-code-npm, claude-code, opencode, codex, amp-cli
- **Creative Tools**: blender, davinci-resolve

### Auto-Allowed: CUDA Ecosystem
Automatically allowed via pattern matching:
- `cuda_*` - CUDA toolkit packages
- `libcu*` - CUDA libraries
- `libnv*` - NVIDIA libraries
- `cudnn*` - cuDNN packages

## Design Principles

### 1. **Defense in Depth**
Unfree policy is enforced at multiple levels (pkgs, unstablePkgs, system, user), ensuring no unfree package can slip through.

### 2. **Explicit Whitelist**
No blanket `allowUnfree = true`. Every unfree package must be explicitly named.

### 3. **Separation of Concerns**
- **Master list**: System drivers and common applications (system-wide)
- **User/Development additions**: Development and creative tools (user-level only)
- **CUDA exception**: ML/AI development ecosystem

### 4. **Predictable Behavior**
Using `allowUnfreePredicate` instead of `allowUnfree = true` ensures:
- No surprises during `nix flake update`
- Clear audit trail of allowed proprietary software
- Easy to review and modify permissions

## Comparison with Alternatives

### ❌ Global Allow (Anti-Pattern)
```nix
# DON'T DO THIS
nixpkgs.config.allowUnfree = true;
```
**Problems**:
- No control over what gets installed
- Security risk: any unfree package can be added
- No visibility into proprietary dependencies

### ✅ Current Approach (Whitelist)
```nix
config.allowUnfreePredicate = pkg:
  builtins.elem (nixpkgs.lib.getName pkg) allowedUnfreePackages || isCudaPackage pkg;
```
**Benefits**:
- Explicit control
- Easy to audit
- Prevents accidental unfree package installation
- Clear separation of system vs user packages

## Adding New Unfree Packages

### For System-Wide Packages (Hardware Drivers & Common Apps)
1. Add to `allowedUnfreePackages` list in `flake.nix` (lines 29-44)
2. Available automatically across all levels (pkgs, unstablePkgs, system config, home-manager)
3. **Use sparingly** - only for essential system components and widely-used applications

### For User/Development Packages (Development & Creative Tools)
1. Add to the additional list in `unstablePkgs` (lines 61-72)
2. Also add to `home-manager.users.gmc` (lines 119-129)
3. **Preferred approach** for development tools and user-specific software

### Example: Adding "cursor" IDE (Development Tool)
```nix
# For user/development tool (RECOMMENDED):
unstablePkgs = import nixpkgs-unstable {
  config.allowUnfreePredicate = pkg:
    builtins.elem (nixpkgs.lib.getName pkg) (allowedUnfreePackages ++ [
      # Development/AI tools
      # ... existing packages ...
      "cursor"
    ]) || isCudaPackage pkg;
};

# Also add to home-manager.users.gmc (lines 119-129)
nixpkgs.config.allowUnfreePredicate = pkg:
  builtins.elem (nixpkgs.lib.getName pkg) (allowedUnfreePackages ++ [
    # Development/AI tools
    # ... existing packages ...
    "cursor"
  ]) || isCudaPackage pkg;
```

### Example: Adding System-Wide Package (Only if necessary)
```nix
# For system-wide essential (use sparingly):
allowedUnfreePackages = [
  # ... existing packages ...
  "zoom"  # Example: communication tool used system-wide
];
```

## Verification

### Check What's Allowed
```bash
# List all packages in allowedUnfreePackages
nix eval .#nixosConfigurations.nixos-gmc.config.nixpkgs.config.allowUnfreePredicate --apply 'f: "check manually in flake.nix"'

# Try to build an unlisted unfree package (should fail)
nix build nixpkgs#vscode  # Error: unfree package

# Build a whitelisted unfree package (should succeed)
nix build nixpkgs#discord
```

### Debug Unfree Issues
```bash
# Find package name for whitelist
nix eval nixpkgs#packageName.pname

# Example
nix eval nixpkgs#discord.pname
# Output: "discord"
```

## Security Considerations

1. **Minimal Unfree Surface**: Only essential unfree packages are allowed
2. **Reproducibility**: Whitelist is version-controlled and auditable
3. **Separation**: User packages don't affect system integrity
4. **CUDA Exception**: ML/AI development requires CUDA; pattern-based allow is acceptable for this ecosystem

## Recommendations

### ✅ Good Practices
- Review `allowedUnfreePackages` periodically
- Remove unused unfree packages
- Prefer free alternatives when available
- Document why each unfree package is necessary

### ⚠️ Maintenance
- Keep CUDA pattern up-to-date with NVIDIA releases
- When removing a package, also remove from whitelist
- Test system rebuild after modifying unfree lists

## Related Files
- **flake.nix**: Core unfree policy definition
- **configuration.nix**: System package declarations
- **home.nix**: User package declarations
- **modules/home/packages.nix**: Detailed package lists

---

**Last Updated**: 2025-10-18
**Configuration Type**: Whitelist-based with CUDA exception
**Revision**: Updated categorization - moved development tools (factory-cli, claude-code-npm) from master whitelist to user/development category
