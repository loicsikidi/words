{pkgs ? import <nixpkgs> {}}: let
in
  with pkgs; {
    html = stdenvNoCC.mkDerivation {
      name = "words";
      src = lib.cleanSource ./.;

      nativeBuildInputs = [hugo go git];

      buildPhase = ''
        runHook preBuild

        echo "hugo version: $(hugo version)"

        hugo --gc --minify

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        dst=$out/website
        mkdir -p "$dst"
        mv public/* "$dst"/

        runHook postInstall
      '';
    };
  }
