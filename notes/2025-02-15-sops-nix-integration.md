# sops-nix Integration Snapshot (2025-02-15)

## Scope

- Added `sops-nix` as a flake input and imported its NixOS/Home Manager modules so both layers can manage encrypted secrets (`flake.nix`).
- Introduced `modules/secrets.nix` to centralize system-level secret defaults and wired it into `configuration.nix` alongside the `sops` CLI package.
- Taught `home.nix` about an optional `secrets/home.yaml`, bundling `sops`, `age`, and `ssh-to-age` in `home.packages` and pointing to the standard AGE key location.
- Documented the expected encryption workflow in `secrets/README.md` and checked in a starter `.sops.yaml` that targets `secrets/(system|home).yaml`.
- Ensured formatting via `nixpkgs-fmt flake.nix configuration.nix home.nix modules/secrets.nix`.

## Next Steps

1. Replace `age1REPLACEWITHYOURAGEPUBLICKEY` inside `.sops.yaml` with a real recipient generated via `ssh-to-age` or `age-keygen`.
2. Create encrypted `secrets/system.yaml` and/or `secrets/home.yaml` with `sops`, then reference them through `sops.secrets.<name>.path` in the appropriate Nix modules.
3. When secrets exist, run `sudo nixos-rebuild test --flake .#nixos-gmc` to confirm decryption paths resolve before `switch`.

