# Factory CLI Flake 예제
# flake.nix

{
  description = "Factory AI CLI (droid) for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Overlay 제공
      overlays.default = import ./overlay.nix;

      # NixOS 모듈
      nixosModules.default = import ./module.nix;

      # home-manager 모듈
      homeManagerModules.default = import ./module.nix;

      # 패키지
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
            config.allowUnfree = true;
          };
        in
        {
          factory-cli = pkgs.factory-cli;
          default = pkgs.factory-cli;
        }
      );

      # Apps (nix run)
      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.factory-cli}/bin/droid";
        };
      });

      # Development shell
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = [ self.packages.${system}.factory-cli ];
            shellHook = ''
              echo "Factory CLI development environment"
              echo "Run 'droid' to start"
            '';
          };
        }
      );
    };
}
