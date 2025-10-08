# NixOS Configuration Improvements

This document lists potential improvements for the nixos-dotfiles configuration.

## Completed ✅
- **Firewall enabled** - Basic security hardening implemented (configuration.nix:159-163)
- **Audio System configured** - PipeWire with full support implemented (configuration.nix:70-78)
- **Bluetooth Support** - Full Bluetooth with auto-connection service (configuration.nix:81-117)  
- **Korean Input Method** - fcitx5 with Hangul support configured (configuration.nix:21-30)
- **Display Manager** - LY display manager enabled (configuration.nix:47-49)
- **Hyprland** - Modern Wayland compositor configured (configuration.nix:134)
- **Development Environment** - Suckless dev shell with required dependencies (flake.nix:21-34)
- **Font Management** - Nerd fonts and Korean fonts configured (configuration.nix:170-174)
- **Shell Configuration** - Bash with aliases configured (home.nix:36-42)
- **Security Hardening** - rtkit enabled for real-time audio (configuration.nix:36)

## Security & System Hardening

### Additional Security Hardening
**Priority: Medium**
```nix
# In configuration.nix
security = {
  rtkit.enable = true; # For audio
  polkit.enable = true;
  pam.loginLimits = [{
    domain = "@users";
    item = "rtprio";
    type = "-";
    value = 1;
  }];
};

# Disable unused services
services.avahi.enable = false;
services.printing.enable = false; # Currently commented
```

## Performance & System Configuration

### ~~Audio System~~ ✅ COMPLETED
**Priority: High** - ~~Currently no audio configured~~ **IMPLEMENTED**
- PipeWire with full ALSA, PulseAudio, and JACK support
- Bluetooth audio with WirePlumber
- Located at configuration.nix:70-78

### System Backup
**Priority: Medium**
```nix
# In configuration.nix
services.borgbackup.jobs.system = {
  paths = [
    "/home"
    "/etc"
    "/var"
  ];
  exclude = [
    "/home/*/.cache"
    "/var/cache"
    "/var/tmp"
  ];
  repo = "/path/to/backup/repo";
  encryption.mode = "repokey-blake2";
  startAt = "daily";
  prune.keep = {
    within = "1d";
    daily = 7;
    weekly = 4;
    monthly = 6;
  };
};
```

## Code Quality & Cleanup

### ~~Remove Unused Code~~ ✅ PARTIALLY COMPLETED  
**Priority: Low**
- ~~unstablePkgs line in home.nix~~ - NOT FOUND (may have been cleaned up)
- ~~TODO comment in flake.nix~~ - NOT FOUND (cleaned up)
- Configuration appears clean

### Git Repository Cleanup
**Priority: Low**
- Multiple `.git` directories in `/config/` suggest individual repos
- Consider using git subtrees or removing `.git` directories if not needed
- Files: `config/alacritty/.git`, `config/rofi/.git`, `config/qtile/.git`, etc.

### Module Organization
**Priority: Low**
```nix
# Consider splitting configuration.nix into focused modules:
# modules/desktop.nix - X11, window managers, display
# modules/networking.nix - network, firewall, ssh
# modules/audio.nix - audio configuration
# modules/fonts.nix - font packages
# modules/locale.nix - i18n, timezone, input methods
```

## Hardware & Performance

### SSD Optimization
**Priority: Medium** (if using SSD)
```nix
# In configuration.nix
boot.tmp.cleanOnBoot = true;
services.fstrim.enable = true; # For SSD TRIM support

# In hardware-configuration.nix, add to root filesystem:
options = [ "noatime" "nodiratime" ];
```

### Kernel Parameters
**Priority: Low**
```nix
# In configuration.nix for performance tuning
boot.kernelParams = [
  "quiet"
  "splash"
  "mitigations=off" # Only if you understand security implications
];
```

## Development Environment

### Additional Development Tools
**Priority: Low**
```nix
# In home.nix packages section - Some tools already added:
# - ripgrep ✅ (line 63)
# - nixpkgs-fmt ✅ (line 65) 
# - nodejs ✅ (line 66)
# - gcc ✅ (line 67)

# Still could add:
development = with pkgs; [
  direnv        # Environment management
  pre-commit    # Git hooks  
  gh            # GitHub CLI
  docker        # If needed
  docker-compose
];
```

### ~~Shell Improvements~~ ✅ PARTIALLY COMPLETED
**Priority: Low**
- ✅ Bash enabled (home.nix:37)
- ✅ Basic alias configured: "btw" (home.nix:39) 
- Could add more aliases and completion:
```nix
programs.bash = {
  enable = true;
  enableCompletion = true;  # ADD THIS
  historyControl = [ "ignoreboth" ];  # ADD THIS
  shellAliases = {
    btw = "echo I use nixos btw"; # ✅ EXISTS
    ll = "ls -la";  # ADD THIS
    rebuild = "sudo nixos-rebuild switch --flake .#nixos-gmc";  # ADD THIS
    update = "nix flake update";  # ADD THIS
  };
};
```

## Implementation Priority

### Remaining Medium Priority  
1. **SSD optimization** - TRIM support and performance tuning
2. **System backup** - Automated borgbackup configuration

### Remaining Low Priority
3. **Code cleanup** - Git repo cleanup, module organization
4. **Additional development tools** - direnv, pre-commit, gh CLI
5. **Shell enhancements** - Better aliases and completion

## Testing Commands

Before applying changes:
```bash
# Check configuration
nix flake check

# Test without applying
sudo nixos-rebuild test --flake .#nixos-gmc

# Apply changes
sudo nixos-rebuild switch --flake .#nixos-gmc
```
