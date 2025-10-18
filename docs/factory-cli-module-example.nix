# Factory CLI NixOS/home-manager Module 예제
# module.nix

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.factory-cli;
in
{
  options.services.factory-cli = {
    enable = mkEnableOption "Factory AI CLI (droid)";

    package = mkOption {
      type = types.package;
      default = pkgs.factory-cli;
      defaultText = literalExpression "pkgs.factory-cli";
      description = "Factory CLI package to use";
    };
  };

  config = mkIf cfg.enable {
    # Overlay 자동 적용
    nixpkgs.overlays = mkBefore [
      (import ./overlay.nix)
    ];

    # Unfree 자동 허용
    nixpkgs.config.allowUnfreePredicate = pkg:
      (lib.getName pkg) == "factory-cli" ||
      (lib.getName pkg) == "steam-unwrapped" ||  # Linux용 steam-run
      config.nixpkgs.config.allowUnfreePredicate pkg or false;

    # 패키지 설치 (home-manager)
    home.packages = mkIf (hasAttr "home" config) [ cfg.package ];

    # 패키지 설치 (NixOS)
    environment.systemPackages = mkIf (hasAttr "environment" config) [ cfg.package ];
  };

  meta.maintainers = with lib.maintainers; [ ];
}
