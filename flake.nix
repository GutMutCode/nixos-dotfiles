# Focus on defining the inputs and assembling the system
{
  description = "NixOS from Scratch";
  inputs = {
    # Core dependencies
    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Custom packages from GitHub
    # When adding new package:
    # 1. Add input here
    # 2. Add to outputs parameters
    # 3. Add to customPackageInputs list in outputs
    factory-cli-nix = {
      url = "github:GutMutCode/factory-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-npm = {
      url = "github:GutMutCode/claude-code-npm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencode-nix = {
      url = "github:GutMutCode/opencode-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    openai-codex-nix = {
      url = "github:GutMutCode/openai-codex-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-doom-emacs-unstraightened = {
      url = "github:marienz/nix-doom-emacs-unstraightened";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, sops-nix, factory-cli-nix, claude-code-npm, opencode-nix, openai-codex-nix, nix-doom-emacs-unstraightened, ... }:
    let
      system = "x86_64-linux";

      # Custom package inputs for DRY (Don't Repeat Yourself)
      # When adding new package: add to inputs above AND this list
      customPackageInputs = [
        factory-cli-nix
        claude-code-npm
        opencode-nix
        openai-codex-nix
      ];

      overlaysList =
        # Custom package overlays (automatically mapped from customPackageInputs)
        (map (pkg: pkg.overlays.default) customPackageInputs)
        # Local development/experimental packages
        ++ [ (import ./custom-pkgs/overlay.nix) ];

      # Unfree packages organized by category
      unfreeCategories = {
        hardware = [
          "nvidia-x11"
          "nvidia-settings"
        ];

        fonts = [
          "corefonts"
        ];

        communication = [
          "discord"
          "slack"
        ];

        media = [
          "spotify"
        ];

        gaming = [
          "steam"
          "steam-unwrapped"
          "steam-original"
          "steam-run"
        ];

        dev-ai = [
          "factory-cli"
          "claude-code-npm"
          "opencode"
          "openai-codex"
          "amp-cli"
        ];

        creative = [
          "blender"
          "davinci-resolve"
          "unityhub"
        ];
      };

      # Profiles: combinations of categories for different users/environments
      unfreeProfiles = {
        # System level: only hardware drivers
        system = [
          "hardware"
        ];

        # Full desktop: all categories
        desktop-full = [
          "hardware"
          "fonts"
          "communication"
          "media"
          "gaming"
          "dev-ai"
          "creative"
        ];

        # Work laptop: no gaming/creative
        laptop-work = [
          "hardware"
          "fonts"
          "communication"
          "dev-ai"
        ];

        # Development only
        dev-only = [
          "hardware"
          "fonts"
          "communication"
          "dev-ai"
        ];

        # Server minimal
        server-minimal = [
          "hardware"
        ];
      };

      # Helper functions
      lib = nixpkgs.lib;

      # Convert category list to package list
      categoriesToPackages = categories:
        lib.flatten (map (cat: unfreeCategories.${cat}) categories);

      # CUDA package detection
      isCudaPackage = pkg:
        let name = lib.getName pkg;
        in builtins.match "^(cuda_.*|libcu.*|libnv.*|cudnn.*)" name != null;

      # Create allowUnfreePredicate from package list
      mkUnfreePredicate = allowedList: pkg:
        builtins.elem (lib.getName pkg) allowedList || isCudaPackage pkg;

      # Create predicate from profile name
      mkProfilePredicate = profileName:
        mkUnfreePredicate (categoriesToPackages unfreeProfiles.${profileName});

      pkgs = import nixpkgs {
        inherit system;
        overlays = overlaysList;
        config.allowUnfreePredicate = mkProfilePredicate "system";
      };

      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        overlays = overlaysList;
        config.allowUnfreePredicate = mkProfilePredicate "desktop-full";
      };
    in
    {
      # Virtual Environment for suckless
      devShells.${system}.suckless = pkgs.mkShell {
        # toolchain + headers/libs
        packages = with pkgs; [
          pkg-config
          xorg.libX11
          xorg.libXft
          xorg.libXinerama
          fontconfig
          freetype
          harfbuzz
          gcc
          gnumake
        ];
      };

      # Configure the `nixos-gmc` host
      nixosConfigurations.nixos-gmc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit unstablePkgs system;
        };
        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            nixpkgs.config.allowUnfreePredicate = mkProfilePredicate "system";
            nixpkgs.overlays = overlaysList;

            home-manager = {
              useGlobalPkgs = false;
              useUserPackages = true;
              sharedModules = [
                sops-nix.homeManagerModules.sops
                nix-doom-emacs-unstraightened.hmModule
              ]
              # Custom package modules (automatically mapped from customPackageInputs)
              ++ (map (pkg: pkg.homeManagerModules.default) customPackageInputs);
              users.gmc = {
                imports = [ ./home.nix ];
                nixpkgs.overlays = overlaysList;
                nixpkgs.config.allowUnfreePredicate = mkProfilePredicate "desktop-full";
              };
              backupFileExtension = "backup";
              extraSpecialArgs = {
                inherit unstablePkgs system;
              };
            };
          }
        ];
      };
    };
}
