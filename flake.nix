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
      pkgs = import nixpkgs { inherit system; overlays = overlaysList; };
      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        overlays = overlaysList;
        config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
          "claude-code"
          "opencode"
          "codex"
          "amp-cli"
        ];
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
            # Allow unfree packages for system-level packages
            nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
              "nvidia-x11"
              "nvidia-settings"
              "factory-cli"
            ];
            nixpkgs.overlays = overlaysList;

            home-manager = {
              useGlobalPkgs = false; # Don't inherit the global packages
              useUserPackages = true;
              sharedModules = [
                sops-nix.homeManagerModules.sops
                { nixpkgs.overlays = overlaysList; }
              ];
              users.gmc = import ./home.nix;
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
