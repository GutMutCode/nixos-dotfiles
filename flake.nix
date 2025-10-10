# Focus on defining the inputs and assembling the system
{
  description = "NixOS from Scratch";
  inputs = {
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
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, sops-nix, ... }:
    let
      system = "x86_64-linux";
      overlaysList = [ (import ./custom-pkgs/overlay.nix) ];
      
      allowedUnfreePackages = [
        "nvidia-x11"
        "nvidia-settings"
        "discord"
        "spotify"
        "steam"
        "steam-unwrapped"
        "steam-original"
        "steam-run"
        "slack"
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
          builtins.elem (nixpkgs.lib.getName pkg) (allowedUnfreePackages ++ [
            "claude-code"
            "opencode"
            "codex"
            "amp-cli"
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
              ];
              users.gmc = {
                imports = [ ./home.nix ];
                nixpkgs.overlays = overlaysList;
                nixpkgs.config.allowUnfreePredicate = pkg:
                  builtins.elem (nixpkgs.lib.getName pkg) (allowedUnfreePackages ++ [
                    "claude-code"
                    "opencode"
                    "codex"
                    "amp-cli"
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
