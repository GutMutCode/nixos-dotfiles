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
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      unstablePkgs = import nixpkgs-unstable { 
        inherit system; 
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
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = false; # Don't inherit the global packages
              useUserPackages = true;
              users.gmc = import ./home.nix;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit unstablePkgs system; };
            };
          }
        ];
      };
    };
}
