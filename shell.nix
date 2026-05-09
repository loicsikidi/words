{
  pkgs ?
    import (fetchTarball
      # pin nixpkgs in order to use hugo v0.160.1
      "https://github.com/NixOS/nixpkgs/archive/01fbdeef22b76df85ea168fbfe1bfd9e63681b30.tar.gz")
    {},
}: let
  helpers = import (builtins.fetchTarball
    "https://github.com/loicsikidi/nix-shell-toolbox/tarball/main") {
    inherit pkgs;
    hooksConfig = {};
  };
in
  pkgs.mkShell {
    buildInputs = with pkgs;
      [
        hugo
      ]
      ++ helpers.packages;

    shellHook = ''
      ${helpers.shellHook}
      echo "Development environment ready!"
      echo "  - Hugo version: $(hugo version)"
    '';

    # to enable debugging with delve
    hardeningDisable = ["fortify"];

    env = {
      CGO_ENABLED = "0";
    };
  }
