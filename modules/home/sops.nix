{ config, lib, ... }:

let
  secretsDir = ../../secrets;
  homeSecretsCandidate = "${secretsDir}/home.yaml";
  homeSecretsPath =
    if builtins.pathExists homeSecretsCandidate then
      builtins.path { path = homeSecretsCandidate; }
    else
      null;
in
{
  sops =
    {
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    }
    // lib.optionalAttrs (homeSecretsPath != null) {
      defaultSopsFile = homeSecretsPath;
      secrets.git-ssh-key = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519_github";
        mode = "0600";
      };
    };
}
