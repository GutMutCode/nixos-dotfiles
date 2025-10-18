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

## Screen Capture Methods

### Recommended: Built-in PipeWire Screen Capture

**What it is:**
- Native OBS screen capture using PipeWire and xdg-desktop-portal
- Modern, stable method for Wayland screen sharing
- Built into OBS Studio (no plugin needed)

**Why recommended:**
- Most stable and actively maintained
- Works seamlessly with Hyprland via xdg-desktop-portal-hyprland
- No segmentation faults or compatibility issues
- Better performance than legacy methods

**How to use:**
1. Sources → Add → "**Screen Capture (PipeWire)**"
2. Portal dialog appears - select monitor to capture
3. Adjust settings as needed

**Requirements:**
- xdg-desktop-portal-hyprland (configured in `modules/desktop/hyprland.nix`)
- PipeWire (standard on NixOS)

**Note:** This captures **video only** (screen content). For audio, use PipeWire Audio Capture plugin (see below).

## Understanding PipeWire Capture Methods

PipeWire is a multimedia framework that handles both video and audio streams. In OBS, these are separated into different source types:

| Source Type | Captures | Examples |
|-------------|----------|----------|
| **Screen Capture (PipeWire)** | Video/Display output | Desktop, game visuals, browser windows |
| **PipeWire Audio Capture** | Audio streams | Game sounds, music, Discord voices, microphone |

### Typical Setup Example

**For game streaming:**
1. **Screen Capture (PipeWire)** → Game screen visuals (video)
2. **Audio Output Capture** → Desktop/Game audio (what you hear)
3. **Audio Input Capture** → Microphone (your voice)

Note: Detailed audio capture explanation is in the obs-pipewire-audio-capture plugin section below.

## Installed Plugins

Current plugins configured in `modules/home/programs.nix`:

### 1. wlrobs (Legacy Wayland Screen Capture)

**⚠️ Note:** This plugin is **not recommended** for modern setups. Use built-in PipeWire screen capture instead.

**What it is:**
- Legacy screen capture plugin for Wayland environments
- Provides two capture methods: dmabuf (GPU) and scpy (CPU)

**Known issues:**
- **dmabuf backend causes segmentation faults** on many systems
- scpy backend has high CPU usage and can cause mouse stuttering
- Less stable than PipeWire-based capture

**How to use (if needed):**
1. Sources → Add → "Wayland output (dmabuf)" or "Wayland output (scpy)"
2. Select screen to capture
3. Set resolution/FPS

**Troubleshooting dmabuf crashes:**
If you must use dmabuf and encounter crashes, add to `config/hypr/settings/environment.conf`:
```bash
env = WLR_DRM_NO_MODIFIERS,1
```

**Migration:** Consider removing wlrobs from your configuration and using PipeWire screen capture instead.

### 2. obs-pipewire-audio-capture

**What it is:**
- PipeWire audio integration plugin
- Captures **audio only** (system sounds, applications, microphone)

**Why needed:**
- Screen Capture (PipeWire) only captures **video**, not audio
- Essential for streaming/recording with sound
- Provides separate control for different audio sources

**Audio Input vs Output:**

PipeWire distinguishes between two types of audio streams:

| Type | Direction | What it captures | Examples |
|------|-----------|------------------|----------|
| **Audio Output Capture** | Device → Speakers | Sound your computer **plays** | Game audio, music, YouTube, Discord friends' voices, system sounds |
| **Audio Input Capture** | Microphone → Computer | Sound your computer **records** | Your microphone, line-in devices, virtual inputs |

**Why they're separated:**

1. **Different sources:** Output = what you hear, Input = what you say
2. **Independent control:** Adjust microphone volume separately from game audio
3. **Separate processing:** Apply noise suppression to mic only, compressor to desktop audio only
4. **Selective recording:** Choose to record desktop audio without microphone, or vice versa

**Audio Capture Methods:**

OBS provides three different ways to capture audio with PipeWire:

| Source Type | What it captures | Use case |
|-------------|------------------|----------|
| **Audio Output Capture** | Physical device (speakers/monitors) | Capture all system audio at once |
| **Audio Input Capture** | Physical device (microphone) | Capture microphone/line-in |
| **Application Audio Capture** | Individual application | Capture specific app with independent control |

### Method 1: Simple Setup (Recommended for beginners)

**Best for:** Quick setup, don't need per-app volume control

**Configuration:**
1. **Settings → Audio → Global Audio Devices:**
   - Desktop Audio: Select your output device (e.g., "LG ULTRAGEAR", "Built-in Audio")
   - Mic/Auxiliary Audio: Select your microphone

**Result:** Desktop Audio captures ALL system sounds automatically (games, browser, Discord, etc.)

**Setup:**
```
Audio (Automatic):
├─ Desktop Audio → All application sounds combined
└─ Mic/Aux → Your microphone
```

**Pros:**
- ✅ Simple one-time setup
- ✅ All new applications automatically included
- ✅ No need to add sources manually

**Cons:**
- ❌ Can't adjust individual app volumes in OBS
- ❌ All apps share same filters/effects

### Method 2: Per-Application Control (Advanced)

**Best for:** Independent volume control, applying different filters per app

**Step 1: Disable Desktop Audio**

Go to **Settings → Audio → Global Audio Devices:**
- Desktop Audio → `Disabled`
- Desktop Audio 2 → `Disabled` (if present)

This prevents global capture so you can add apps individually.

**Step 2: Add Individual Applications**

For each application you want to capture:

1. **Sources → Add → "Application Audio Capture (PipeWire)"**
2. Name it clearly (e.g., "Firefox Audio", "Game Audio", "Discord Audio")
3. Select the application from the dropdown
4. Click OK

**Step 3: Add Microphone**

**Sources → Add → "Audio Input Capture (PipeWire)"**
- Select your microphone device

**Setup:**
```
Audio Sources (Manual):
├─ Application Audio Capture → Firefox
├─ Application Audio Capture → Game
├─ Application Audio Capture → Discord [optional]
└─ Audio Input Capture → Microphone
```

**Pros:**
- ✅ Independent volume control per app
- ✅ Apply different filters per app (e.g., compressor on game only)
- ✅ Can mute/unmute specific apps

**Cons:**
- ❌ Must add new apps manually
- ❌ More complex setup

### Method 3: Hybrid Approach

Combine both methods:
- Desktop Audio for general system sounds
- Application Audio Capture for specific apps you want to control separately

**Example:**
```
Audio Sources:
├─ Desktop Audio → Background music, system sounds
├─ Application Audio Capture → Game (independent volume)
└─ Audio Input Capture → Microphone
```

### Troubleshooting Application Audio Capture

**Problem: Application doesn't appear in dropdown**

1. Make sure the application is **actively playing audio**
2. Check that Desktop Audio is **disabled** (it may conflict)
3. Try changing **Match Priority** in source properties:
   - Right-click source → Properties
   - Try both "App Name First" and "Binary Name First"

4. Restart PipeWire:
   ```bash
   systemctl --user restart pipewire pipewire-pulse
   ```
   Then restart OBS

5. Check available applications:
   ```bash
   pw-cli list-objects | grep -B 2 "Stream/Output/Audio"
   ```

**Problem: No audio detected (volume bar not moving)**

1. Verify the application is playing sound (check system volume)
2. Try selecting a different device/application
3. Make sure you're using the correct capture type:
   - **Audio Output Capture** → Device (speakers)
   - **Application Audio Capture** → App (Firefox, game)
4. Check if Desktop Audio is capturing it instead (disable if needed)

### Quick Reference

**Finding your audio devices:**
```bash
# List output devices (speakers/monitors)
pw-cli list-objects | grep -A 5 "Audio/Sink"

# List input devices (microphones)
pw-cli list-objects | grep -A 5 "Audio/Source"

# List active applications
pw-cli list-objects | grep -B 2 "Stream/Output/Audio"
```

Common device names on this system:
- **LG ULTRAGEAR** - HDMI monitor audio
- **ALC897 Digital** - Motherboard digital output
- **fifine Microphone** - USB microphone (can be output or input)
- **Bluetooth devices** - Wireless audio

### 3. obs-vkcapture (Vulkan/OpenGL Game Capture)

**What it is:**
- High-performance game capture plugin
- Captures game rendering directly via GPU
- Supports both **Vulkan** and **OpenGL** games

**Why needed:**
- Lower CPU usage than screen capture (can achieve <1% CPU)
- Higher quality, no frame drops
- Captures game output before compositing
- Essential for performance-sensitive streaming

**Supported games:**
- Vulkan games: Most modern games
- OpenGL games: Project Zomboid, Minecraft, older titles
- Must be **injected at game launch time**

**How to use:**

#### Method 1: Steam Games (Recommended)

1. **Open Steam Library**
2. Right-click game → **Properties**
3. **Launch Options** → Enter:
   ```
   obs-vkcapture %command%
   ```
4. Launch game from Steam

#### Method 2: Non-Steam Games

```bash
obs-vkcapture /path/to/game_executable
```

Example for Steam itself:
```bash
obs-vkcapture steam steam://rungameid/108600
```

#### Method 3: In OBS

After launching game with obs-vkcapture:

1. **Sources → Add → "Game Capture (Vulkan/OpenGL)"**
2. Properties:
   - Capture Method: `Capture specific window`
   - Window: Select `[obs-vkcapture]: GameName`
3. OK

**Important notes:**
- ⚠️ Must inject **before** game starts (can't capture already-running games)
- ⚠️ Game restart required when changing capture method
- ✅ Works with OpenGL games (not just Vulkan)

**When to use vs Screen Capture:**

| Scenario | Recommended Method |
|----------|-------------------|
| High-performance streaming | obs-vkcapture |
| CPU-intensive games | obs-vkcapture |
| Quick/casual recording | Screen Capture (PipeWire) |
| Already-running game | Screen Capture (PipeWire) |
| Multiple games switching | Screen Capture (PipeWire) |

**Example: Project Zomboid (OpenGL game)**

1. Add launch option: `obs-vkcapture %command%`
2. Launch game
3. OBS → Game Capture → Select `[obs-vkcapture]: ProjectZomboid64`
4. Game window will appear in OBS

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
    wlrobs  # Optional: Legacy plugin, use PipeWire screen capture instead
    obs-pipewire-audio-capture
    obs-vkcapture
    obs-backgroundremoval
  ];
};
```

**Note:** Consider removing `wlrobs` from the plugin list if you use PipeWire screen capture exclusively.

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

### OBS crashes when adding wlrobs source (Segmentation fault)

**Symptom:**
```
info: - source: 'Wayland output(dmabuf)' (wlrobs-dmabuf)
Segmentation fault (core dumped)
```

**Solution:**
1. **Recommended:** Use "Screen Capture (PipeWire)" instead of wlrobs
2. **Alternative:** Try "Wayland output (scpy)" instead of dmabuf
3. **Workaround:** Add to `config/hypr/settings/environment.conf`:
   ```bash
   env = WLR_DRM_NO_MODIFIERS,1
   ```

### Screen capture not working (PipeWire method)

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

4. Verify PipeWire is running:
   ```bash
   systemctl --user status pipewire
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
