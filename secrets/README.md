# Secrets Directory

This folder stores encrypted secrets managed by [sops-nix](https://github.com/Mic92/sops-nix) and should be committed to the repository. The files that contain real secret data must be encrypted with `sops` before committing.

## Recommended workflow

1. **Generate or reuse an age key**
   - Convert the host SSH key (already present on NixOS) to an age recipient: `ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key > /etc/ssh/ssh_host_ed25519_key.age`
   - Or generate a dedicated user key: `age-keygen -o ~/.config/sops/age/keys.txt`
   These steps follow the guidance in the sops-nix README on using SSH or age keys for encryption.

2. **Configure recipients**
   - Add the resulting public key(s) to `.sops.yaml` (see this repo) so new secrets automatically use the right recipients.

3. **Create or edit a secret file**
   - Example: `sops --input-type yaml --output-type yaml --encrypted-regex '^(data|secret)$' --filename secrets/system.yaml secrets/system.yaml`
   - `sops` reads the rules in `.sops.yaml`, encrypts in place, and drops metadata that sops-nix uses at activation time. The behaviour matches the workflow described in the upstream README.

4. **Reference the secret in Nix**
   - Define it in `modules/secrets.nix` or within `home.nix` using `sops.secrets.<name>.path`. At activation time sops-nix will decrypt to `/run/secrets` (system) or `$XDG_RUNTIME_DIR/secrets.d` (home-manager), as documented upstream.

Only encrypted files should be checked in here. Plain-text drafts should be removed before committing.

