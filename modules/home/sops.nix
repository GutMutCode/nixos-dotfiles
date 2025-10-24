{ config, lib, ... }:

let
  helpers = import ../../lib/helpers.nix { inherit lib; };
  secretsPath = helpers.mkSecretsPath ../../secrets "home.yaml";
in
{
  sops =
    {
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    }
    // helpers.mkSecretsConfig secretsPath
    // lib.optionalAttrs (secretsPath != null) {
      secrets.git-ssh-key = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519_github";
        mode = "0600";
      };
    };
}
