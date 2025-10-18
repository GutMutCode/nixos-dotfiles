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
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, sops-nix, factory-cli-nix, claude-code-npm, opencode-nix, ... }:
    let
      system = "x86_64-linux";

      # Custom package inputs for DRY (Don't Repeat Yourself)
      # When adding new package: add to inputs above AND this list
      customPackageInputs = [
        factory-cli-nix
        claude-code-npm
        opencode-nix
      ];

      overlaysList =
        # Custom package overlays (automatically mapped from customPackageInputs)
        (map (pkg: pkg.overlays.default) customPackageInputs)
        # Local development/experimental packages
        ++ [ (import ./custom-pkgs/overlay.nix) ];

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

      isCudaPackage = pkg:
        let name = nixpkgs.lib.getName pkg;
        in builtins.match "^(cuda_.*|libcu.*|libnv.*|cudnn.*)" name != null;

      pkgs = import nixpkgs {
        inherit system;
        overlays = overlaysList;
        config.allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg) allowedUnfreePackages || isCudaPackage pkg;
      };

      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        overlays = overlaysList;
        config.allowUnfreePredicate = pkg:
          builtins.elem (nixpkgs.lib.getName pkg)
            (allowedUnfreePackages ++ [
              # Development/AI tools
              "factory-cli"
              "claude-code-npm"
              "opencode"
              "openai-codex"
              "amp-cli"
              # Creative tools
              "blender"
              "davinci-resolve"
            ]) || isCudaPackage pkg;
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
            nixpkgs.config.allowUnfreePredicate = pkg:
              builtins.elem (nixpkgs.lib.getName pkg) allowedUnfreePackages || isCudaPackage pkg;
            nixpkgs.overlays = overlaysList;

            home-manager = {
              useGlobalPkgs = false;
              useUserPackages = true;
              sharedModules = [
                sops-nix.homeManagerModules.sops
              ]
              # Custom package modules (automatically mapped from customPackageInputs)
              ++ (map (pkg: pkg.homeManagerModules.default) customPackageInputs);
              users.gmc = {
                imports = [ ./home.nix ];
                nixpkgs.overlays = overlaysList;
                nixpkgs.config.allowUnfreePredicate = pkg:
                  builtins.elem (nixpkgs.lib.getName pkg)
                    (allowedUnfreePackages ++ [
                      # Development/AI tools
                      "factory-cli"
                      "claude-code-npm"
                      "opencode"
                      "openai-codex"
                      "amp-cli"
                      # Creative tools
                      "blender"
                      "davinci-resolve"
                    ]) || isCudaPackage pkg;
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
