{ lib, ... }:

let
  secretsDir = ../secrets;
  systemSecretsCandidate = "${secretsDir}/system.yaml";
  systemSecretsPath =
    if builtins.pathExists systemSecretsCandidate then
      builtins.path { path = systemSecretsCandidate; }
    else
      null;
in
{
  config.sops =
    {
      age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    }
    // lib.optionalAttrs (systemSecretsPath != null) {
      defaultSopsFile = systemSecretsPath;
    };
}
