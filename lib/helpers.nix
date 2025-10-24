{ lib }:
{
  # Create a secrets file path if it exists, otherwise return null
  # Used for sops-nix configuration
  mkSecretsPath = baseDir: fileName:
    let
      candidate = "${baseDir}/${fileName}";
    in
    if builtins.pathExists candidate
    then builtins.path { path = candidate; }
    else null;

  # Create sops configuration attributes from a secrets path
  # Returns empty attrset if path is null
  mkSecretsConfig = secretsPath:
    lib.optionalAttrs (secretsPath != null) {
      defaultSopsFile = secretsPath;
    };
}
