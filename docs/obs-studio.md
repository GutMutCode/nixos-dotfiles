# OBS Studio Setup Guide

Configuration guide for OBS Studio on NixOS with Wayland (Hyprland) and PipeWire.

## Table of Contents

1. [Overview](#overview)
2. [Installed Plugins](#installed-plugins)
3. [Virtual Camera](#virtual-camera)
4. [Usage](#usage)
5. [Configuration Files](#configuration-files)

## Overview

**Open Broadcaster Software** - Free and open-source streaming/recording software.

### Main Uses
- Twitch/YouTube live streaming
- Gameplay recording
- Online lecture video production
- Advanced video conferencing features (virtual camera)
- Screen recording and editing

### Key Features
- Screen/window/region capture
- Webcam integration and compositing
- Multiple source (Scene) mixing
- Audio mixing and filtering
- Real-time streaming
- Local recording

## Installed Plugins

Current plugins configured in `modules/home/programs.nix`:

### 1. wlrobs (Wayland Screen Capture)

**What it is:**
- Screen capture plugin for Wayland environments
- Supports wlroots-based compositors (Hyprland, Sway, etc.)

**Why needed:**
- Unlike X11, Wayland restricts screen capture for security
- xdg-desktop-portal provides screen sharing API
- wlrobs bridges OBS with Wayland screen sharing protocol

**How to use:**
1. Sources → Add → "Wayland output (wlrobs)"
2. Select screen to capture
3. Set resolution/FPS

### 2. obs-pipewire-audio-capture

**What it is:**
- PipeWire audio integration plugin
- Captures system audio/microphone directly

**Why needed:**
- NixOS uses PipeWire for audio management
- Provides advanced audio routing and low latency
- Captures application audio separately

**How to use:**
1. Sources → Add → "PipeWire Audio Capture"
2. Select application or device to capture
3. Configure volume/filters

### 3. obs-vkcapture (Vulkan Game Capture)

**What it is:**
- High-performance game capture using Vulkan API
- Captures game rendering directly

**Why needed:**
- Lower CPU usage than screen capture
- Higher quality, no frame drops
- Essential for game streaming

**How to use:**
```bash
obs-vkcapture game_executable
```

Example:
```bash
obs-vkcapture steam
```

**Note:** Game must use Vulkan API

### 4. obs-backgroundremoval (AI Background Removal)

**What it is:**
- AI-powered real-time background removal
- No green screen required

**Why needed:**
- Professional look for webcam streaming
- Works in any environment
- ML-based person detection

**How to use:**
1. Add webcam source
2. Right-click → Filters → Add → "Background Removal"
3. Adjust threshold/blur settings

**Requirements:**
- Moderate GPU power (uses CUDA if available)
- Configured with `cudaSupport = true` in `modules/home/programs.nix`

## Virtual Camera

Virtual camera feature turns OBS output into a virtual webcam device.

### What it is
- Makes OBS scenes appear as a webcam in other applications
- Allows use of OBS compositing in Zoom/Discord/etc.

### Configuration Location
`configuration.nix` (now in `modules/hardware/obs-virtual-camera.nix`):

```nix
boot.kernelModules = [ "v4l2loopback" ];
boot.extraModprobeConfig = ''
  options v4l2loopback exclusive_caps=1 devices=2 video_nr=0,1 card_label="OBS Virtual Camera"
'';
```

### How to use

1. **Start Virtual Camera in OBS:**
   - Controls → Start Virtual Camera

2. **Select in other applications:**
   - Zoom/Discord: Settings → Video → Camera → "OBS Virtual Camera"
   - Browser: Allow camera access → Select "OBS Virtual Camera"

3. **Check device:**
   ```bash
   v4l2-ctl --list-devices
   ```

### Use Cases
- Add overlays/backgrounds to video calls
- Picture-in-picture with screen sharing
- Multi-source compositing for presentations
- Apply filters/effects in real-time

## Usage

### Basic Workflow

1. **Add Sources:**
   - Scene → Add Source
   - Choose type (screen/webcam/audio/etc.)
   - Configure settings

2. **Configure Audio:**
   - Settings → Audio
   - Select PipeWire devices
   - Set sample rate (48kHz recommended)

3. **Start Recording/Streaming:**
   - Settings → Output → Configure encoder
   - Use NVENC (NVIDIA GPU) for hardware encoding
   - Controls → Start Recording/Streaming

### Recommended Settings for NixOS

**Video Settings:**
- Base Resolution: Your monitor resolution
- Output Resolution: 1920x1080 (Full HD)
- FPS: 60 (gaming), 30 (general)

**Output Settings:**
- Encoder: NVENC H.264 (NVIDIA GPU)
- Rate Control: CBR (streaming), CQP (recording)
- Bitrate: 6000 Kbps (1080p60), 4500 Kbps (1080p30)
- Preset: Quality

**Audio Settings:**
- Sample Rate: 48 kHz
- Channels: Stereo
- Desktop Audio: PipeWire device
- Mic/Auxiliary: PipeWire input device

### Keybinds

Configure in Settings → Hotkeys:
- Start/Stop Recording: F10
- Start/Stop Streaming: F11
- Mute/Unmute Mic: F12
- Switch Scene: Ctrl+1, Ctrl+2, etc.

## Configuration Files

### OBS Configuration
```
~/.config/obs-studio/
├── basic/
│   ├── profiles/     # Encoder/output settings
│   └── scenes/       # Scene collections
├── plugin_config/    # Plugin-specific settings
└── global.ini        # Global OBS settings
```

### NixOS Configuration

**System-level (Virtual Camera):**
- `modules/hardware/obs-virtual-camera.nix`

**User-level (OBS + Plugins):**
- `modules/home/programs.nix`

```nix
obs-studio = {
  enable = true;
  package = (pkgs.obs-studio.override {
    cudaSupport = true;
  });
  plugins = with pkgs.obs-studio-plugins; [
    wlrobs
    obs-pipewire-audio-capture
    obs-vkcapture
    obs-backgroundremoval
  ];
};
```

### XDG Desktop Portal (Screen Sharing)

Required for Wayland screen capture:

`modules/desktop/hyprland.nix`:
```nix
xdg.portal = {
  enable = true;
  extraPortals = with pkgs; [
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
  ];
  config.common.default = [ "hyprland" "gtk" ];
};
```

## Troubleshooting

### Screen capture not working

1. Check portal is running:
   ```bash
   systemctl --user status xdg-desktop-portal-hyprland
   ```

2. Restart portal:
   ```bash
   systemctl --user restart xdg-desktop-portal-hyprland
   ```

3. Check OBS logs:
   ```bash
   journalctl --user -u obs -f
   ```

### Virtual camera not appearing

1. Check v4l2loopback module:
   ```bash
   lsmod | grep v4l2loopback
   ```

2. Reload module:
   ```bash
   sudo modprobe -r v4l2loopback
   sudo modprobe v4l2loopback
   ```

3. Verify devices:
   ```bash
   v4l2-ctl --list-devices
   ```

### Audio not captured

1. Check PipeWire status:
   ```bash
   systemctl --user status pipewire pipewire-pulse
   ```

2. List audio devices:
   ```bash
   pactl list sources
   pactl list sinks
   ```

3. Test audio in OBS:
   - Settings → Audio → Desktop Audio Device
   - Select correct PipeWire device

### Background removal not working

1. Check CUDA support:
   ```bash
   nvidia-smi
   ```

2. Check OBS logs for CUDA errors

3. Ensure `cudaSupport = true` in configuration

## References

- **OBS Project:** https://obsproject.com/
- **wlrobs:** https://sr.ht/~scoopta/wlrobs/
- **obs-pipewire-audio-capture:** https://github.com/dimtpap/obs-pipewire-audio-capture
- **obs-vkcapture:** https://github.com/nowrep/obs-vkcapture
- **obs-backgroundremoval:** https://github.com/royshil/obs-backgroundremoval
