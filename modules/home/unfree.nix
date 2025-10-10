{ lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    let
      name = lib.getName pkg;
      allowedPackages = [
        "discord"
        "spotify"
        "steam"
        "steam-unwrapped"
        "slack"
        "blender"
      ];
      isCudaPackage = builtins.match "^(cuda_.*|libcu.*|libnv.*)" name != null;
    in
    builtins.elem name allowedPackages || isCudaPackage;
}
