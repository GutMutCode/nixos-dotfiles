{ lib, ... }:

let
  helpers = import ../lib/helpers.nix { inherit lib; };
  secretsPath = helpers.mkSecretsPath ../secrets "system.yaml";
in
{
  config.sops =
    {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    }
    // helpers.mkSecretsConfig secretsPath;
}
