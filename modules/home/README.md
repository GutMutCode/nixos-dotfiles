# Home Manager Modules

## Note on Unfree Packages

The `unfree.nix` module is deprecated and should not be used when `useGlobalPkgs = false`.

Unfree package configuration is now managed centrally in `flake.nix` using `allowUnfreePredicate`.

To add a new unfree package:
1. Add the package name to `allowedUnfreePackages` list in `flake.nix`
2. The configuration will be applied to both system and home-manager contexts
