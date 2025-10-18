{ lib
, stdenv
, fetchurl
, makeWrapper
, nodejs
, autoPatchelfHook
, glibc
}:

let
  version = "0.47.0";
  
  src = fetchurl {
    url = "https://registry.npmjs.org/@openai/codex/-/codex-${version}.tgz";
    hash = "sha256-M15YDkb1HmRRALNkYkBs9L24eIRS1Ssp0RAiqLCPdEE=";
  };
in
stdenv.mkDerivation {
  pname = "openai-codex";
  inherit version src;

  nativeBuildInputs = [ makeWrapper ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ glibc ];

  sourceRoot = "package";

  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/openai-codex
    cp -r . $out/lib/openai-codex/

    chmod +x $out/lib/openai-codex/bin/codex.js

    makeWrapper ${nodejs}/bin/node $out/bin/codex \
      --add-flags "$out/lib/openai-codex/bin/codex.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "OpenAI Codex CLI - AI-powered coding assistant";
    homepage = "https://github.com/openai/codex";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    maintainers = [ ];
    mainProgram = "codex";
  };
}
