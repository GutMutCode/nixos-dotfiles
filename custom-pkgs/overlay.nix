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

  rgSha256 = {
    "x86_64-linux" = "61448b1b86e5a14f7b686315089332616f9a626a5716c5617a6a4380e159a22f";
    "aarch64-linux" = "17e57319c5c767f4c94b05a761e06e00b84f32997195c613e54be00227183180";
    "x86_64-darwin" = "e5a7b822d56715b4ad1f6dd4d28913b41d00c4c47f711c21b72e9a2656914b10";
    "aarch64-darwin" = "121f087813a30c511516e0b577322304958f000490b6a70e7025805e26715f33";
  };

  droidSrc = prev.fetchurl {
    url = "${baseUrl}/factory-cli/releases/${version}/${platform}/${arch}/droid";
    sha256 = droidSha256.${systemKey};
  };

  rgSrc = prev.fetchurl {
    url = "${baseUrl}/ripgrep/${platform}/${arch}/rg";
    sha256 = rgSha256.${systemKey};
  };
in
{
  factory-cli = prev.stdenv.mkDerivation {
    pname = "factory-cli";
    inherit version;

    srcs = [ droidSrc rgSrc ];
    sourceRoot = ".";

    nativeBuildInputs = [ ]
      ++ lib.optionals stdenv.isLinux [ prev.autoPatchelfHook prev.makeWrapper ]
      ++ lib.optionals stdenv.isDarwin [ prev.makeWrapper ];

    buildInputs = [ ]
      ++ lib.optionals stdenv.isLinux [ prev.glibc ];

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    dontCheck = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 ${droidSrc} $out/bin/droid
      rg_dir="$out/libexec/factory-cli"
      install -Dm755 ${rgSrc} "$rg_dir/rg"
      ${prev.makeWrapper}/bin/makeWrapper $out/bin/droid $out/bin/droid \
        --prefix PATH : "$rg_dir"
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

