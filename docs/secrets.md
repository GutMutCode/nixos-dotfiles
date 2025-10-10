# Secrets Management

Guide for managing encrypted secrets with sops-nix.

## Overview

This directory stores encrypted secrets managed by [sops-nix](https://github.com/Mic92/sops-nix). Files containing real secret data must be encrypted with `sops` before committing.

## Setup Workflow

### 1. Generate or Reuse an Age Key

**Convert the host SSH key:**
```bash
ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key > /etc/ssh/ssh_host_ed25519_key.age
```

**Or generate a dedicated user key:**
```bash
age-keygen -o ~/.config/sops/age/keys.txt
```

These steps follow the guidance in the sops-nix README on using SSH or age keys for encryption.

### 2. Configure Recipients

Add the resulting public key(s) to `.sops.yaml` (see this repo) so new secrets automatically use the right recipients.

### 3. Create or Edit a Secret File

**Example:**
```bash
sops --input-type yaml --output-type yaml --encrypted-regex '^(data|secret)$' secrets/system.yaml
```

`sops` reads the rules in `.sops.yaml`, encrypts in place, and drops metadata that sops-nix uses at activation time. The behaviour matches the workflow described in the upstream README.

### 4. Reference the Secret in Nix

Define it in `modules/secrets.nix` or within `modules/home/sops.nix` using `sops.secrets.<name>.path`. 

At activation time sops-nix will decrypt to:
- `/run/secrets` (system)
- `$XDG_RUNTIME_DIR/secrets.d` (home-manager)

As documented upstream.

**Important:** Only encrypted files should be checked in here. Plain-text drafts should be removed before committing.

## Git SSH Key Management

When you want Git to use an SSH key managed by Home Manager:

### 1. Create secrets/home.yaml

```bash
sops --input-type yaml --output-type yaml secrets/home.yaml
```

The file can start empty.

### 2. Add Your Private Key

Add your private key under the `git-ssh-key` entry:

```yaml
git-ssh-key: |
  -----BEGIN OPENSSH PRIVATE KEY-----
  ...
  -----END OPENSSH PRIVATE KEY-----
```

Make sure the private key has no extra blank lines at the top or bottom.

### 3. Save the File

`sops` will encrypt it in place using the recipients from `.sops.yaml`.

### 4. Rebuild the System

```bash
sudo nixos-rebuild switch --flake .#nixos-gmc
```

After rebuilding, the key is written to `~/.ssh/id_ed25519_github` with `0600` permissions and `ssh-agent` is started with `AddKeysToAgent confirm`.

With the configuration in `modules/home/programs.nix`, Git and `ssh` will automatically use `~/.ssh/id_ed25519_github` when connecting to `github.com`.

## Configuration Files

### System Secrets

**Location:** `modules/secrets.nix`

```nix
{
  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = ../secrets/system.yaml;
  };
}
```

### Home Secrets

**Location:** `modules/home/sops.nix`

```nix
{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/home.yaml;
    secrets.git-ssh-key = {
      path = "${config.home.homeDirectory}/.ssh/id_ed25519_github";
      mode = "0600";
    };
  };
}
```

### .sops.yaml

**Location:** `.sops.yaml` (repository root)

```yaml
keys:
  - &admin age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

creation_rules:
  - path_regex: secrets/system.yaml$
    key_groups:
      - age:
          - *admin

  - path_regex: secrets/home.yaml$
    key_groups:
      - age:
          - *admin
```

## Usage Examples

### Creating a New Secret

```bash
sops secrets/system.yaml
```

Add your secrets in YAML format:

```yaml
example-api-key: "secret-value"
database-password: "another-secret"
```

### Editing an Existing Secret

```bash
sops secrets/home.yaml
```

### Referencing in NixOS Configuration

**System-level:**
```nix
{
  sops.secrets.example-api-key = {};
  
  services.myservice = {
    apiKeyFile = config.sops.secrets.example-api-key.path;
  };
}
```

**Home-level:**
```nix
{
  sops.secrets.git-ssh-key = {
    path = "${config.home.homeDirectory}/.ssh/id_ed25519_github";
    mode = "0600";
  };
}
```

## Troubleshooting

### Secret not decrypting

1. Check age key exists:
   ```bash
   ls -la ~/.config/sops/age/keys.txt
   ls -la /etc/ssh/ssh_host_ed25519_key
   ```

2. Verify public key in `.sops.yaml`:
   ```bash
   cat .sops.yaml
   ```

3. Test decryption manually:
   ```bash
   sops -d secrets/home.yaml
   ```

### Permission denied

1. Check file permissions:
   ```bash
   ls -la /run/secrets/
   ls -la $XDG_RUNTIME_DIR/secrets.d/
   ```

2. Verify sops-nix service status:
   ```bash
   systemctl status sops-nix
   systemctl --user status sops-nix
   ```

### Key format errors

1. Ensure no extra whitespace in YAML
2. Check key format matches sops requirements
3. Validate YAML syntax:
   ```bash
   sops -d secrets/home.yaml | yq eval
   ```

## Security Best Practices

1. **Never commit unencrypted secrets**
   - Always use `sops` to encrypt before `git add`
   - Check `git diff` before committing

2. **Use separate keys for system/user**
   - System: `/etc/ssh/ssh_host_ed25519_key`
   - User: `~/.config/sops/age/keys.txt`

3. **Backup age keys securely**
   - Store in password manager
   - Keep offline backup

4. **Rotate keys periodically**
   - Generate new age key
   - Re-encrypt secrets with new key
   - Update `.sops.yaml`

5. **Limit secret scope**
   - Use separate files for different services
   - Apply principle of least privilege

## References

- **sops-nix:** https://github.com/Mic92/sops-nix
- **sops:** https://github.com/getsops/sops
- **age encryption:** https://age-encryption.org/
