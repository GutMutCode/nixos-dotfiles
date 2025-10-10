final: prev:
let
  stdenv = prev.stdenv;
  lib = prev.lib;
  arch =
    if stdenv.hostPlatform.isAarch64 then "arm64"
    else if stdenv.hostPlatform.isx86_64 then "x64"
    else throw "Unsupported architecture for factory-cli";
  platform =
    if stdenv.hostPlatform.isLinux then "linux"
    else if stdenv.hostPlatform.isDarwin then "darwin"
    else throw "Unsupported OS for factory-cli";
  systemKey = stdenv.hostPlatform.system;
  version = "0.19.5";
  baseUrl = "https://downloads.factory.ai";

  droidSha256 = {
    "x86_64-linux" = "39c0b2da114948a27b91d295058c42512f43058b88d2dd9413988582f3efc976";
    "aarch64-linux" = "187e59715560b457f59d9c22e432d56a0fc40e90c41031c554e7d432b404d092";
    "x86_64-darwin" = "6f5f84d68249a04f98145451e51b6e4e5e40624e75443d3b6641ab3818e392ff";
    "aarch64-darwin" = "3c3a9f0f9c21b3394622b102b48a0f0230283f32a763ac876ab39501a4e2176a";
  };

  droidSRI = {
    "x86_64-linux" = "sha256-cxRrQpYKaeYsMYYZ0ZilL1stE4rPE/pqObz6drqR5vc=";
  };

  droidSrc = prev.fetchurl (
    { url = "${baseUrl}/factory-cli/releases/${version}/${platform}/${arch}/droid"; }
    // (if droidSRI ? ${systemKey}
    then { hash = droidSRI.${systemKey}; }
    else { sha256 = droidSha256.${systemKey}; })
  );
in
{
  factory-cli = prev.stdenv.mkDerivation {
    pname = "factory-cli";
    inherit version;

    srcs = [ droidSrc ];
    sourceRoot = ".";

    nativeBuildInputs = [ ]
      ++ lib.optionals stdenv.isLinux [ prev.autoPatchelfHook ];

    buildInputs = [ ]
      ++ lib.optionals stdenv.isLinux [ prev.glibc ];

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    dontCheck = true;

    installPhase = ''
            runHook preInstall
            install -Dm755 ${droidSrc} "$out/libexec/factory-cli/droid"
            mkdir -p "$out/bin"
            cat > "$out/bin/droid" <<'EOF'
      #!/usr/bin/env bash
      export PATH="${prev.ripgrep}/bin:$PATH"
      exec "$(dirname "$(readlink -f "$0")")/../libexec/factory-cli/droid" "$@"
      EOF
            chmod +x "$out/bin/droid"
            runHook postInstall
    '';

    meta = {
      description = "Command-line interface for Factory AI";
      homepage = "https://factory.ai/";
      license = lib.licenses.unfree;
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
    };
  };
}
