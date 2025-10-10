{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./modules/secrets.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # SSD optimization
  boot.tmp.cleanOnBoot = true;
  services.fstrim.enable = true; # TRIM support for SSD

  networking.hostName = "nixos-gmc";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Seoul";

  # System locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "ko_KR.UTF-8/UTF-8" ];
  # Input method for Korean - using fcitx5
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-hangul # Korean input
        fcitx5-gtk # GTK integration
      ];
    };
  };

  # Enable dconf (still useful for some applications)
  programs.dconf.enable = true;

  # Enable rtkit for PipeWire real-time audio
  security.rtkit.enable = true;

  # TTY locale
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Wayland login manager
  services.greetd = {
    enable = true;
    package = pkgs.greetd.tuigreet;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd ${config.programs.hyprland.package}/bin/Hyprland";
        user = "greeter";
      };
    };
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound with PipeWire - To offer capture and playback (AV)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    # Bluetooth audio support
    wireplumber.enable = true;
  };

  # Enable hardware graphics acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for Steam
  };

  # NVIDIA GPU drivers (RTX 4080 SUPER)
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # Modesetting required for Wayland compositors (Hyprland)
    modesetting.enable = true;

    # Power management (experimental)
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Use open source kernel modules (recommended for RTX 20 series and newer)
    open = true;

    # Enable nvidia-settings menu
    nvidiaSettings = true;

    # Driver version: stable (570.153.02)
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        AutoConnect = true;
        FastConnectable = true;
        Experimental = true; # Show battery
      };
      Policy = {
        AutoEnable = true; #
      };
    };
  };
  services.blueman.enable = true;

  # Auto-connect to trusted Bluetooth devices on login
  systemd.user.services.bluetooth-auto-connect = {
    description = "Auto-connect to trusted Bluetooth devices";
    after = [ "bluetooth.service" ];
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "bluetooth-auto-connect" ''
        sleep 3
        ${pkgs.bluez}/bin/bluetoothctl power on
        sleep 2
        # Connect to all trusted devices
        for device in $(${pkgs.bluez}/bin/bluetoothctl devices Trusted | ${pkgs.coreutils}/bin/cut -d' ' -f2); do
          echo "Connecting to trusted device: $device"
          ${pkgs.bluez}/bin/bluetoothctl connect "$device"
        done
      '';
      RemainAfterExit = true;
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gmc = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;

  # Hyprland configuration
  programs.hyprland.enable = true;

  # Desktop portals for Wayland (screen sharing / OBS capture)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = [ "hyprland" "gtk" ];
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    alacritty
    sops
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon with security hardening
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
    ports = [ 22 ];
  };

  # Configure firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ]; # SSH enabled
    # allowedUDPPorts = [ ];
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      maple-mono.NF-CN-unhinted
      nerd-fonts.jetbrains-mono
      nerd-fonts.d2coding
    ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Automatic security updates
  system.autoUpgrade = {
    enable = true;
    flake = "path:${./.}";
    flags = [
      "--update-input"
      "nixpkgs"
      "--update-input"
      "nixpkgs-unstable"
      "--accept-flake-config"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };


  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05";

}
