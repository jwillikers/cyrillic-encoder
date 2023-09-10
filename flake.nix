{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs }:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    # This is our new package for end-users
    packages.x86_64-linux.default = pkgs.qt6Packages.callPackage ./build.nix {};

    devShells.x86_64-linux.default = pkgs.mkShell {
      # The shell references this package to provide its dependencies
      inputsFrom = [ self.packages.x86_64-linux.default ];
      buildInputs = with pkgs; [
        gdb

        # this is for the shellhook portion
        qt6.wrapQtAppsHook
        makeWrapper
        bashInteractive
      ];
      # set the environment variables that unpatched Qt apps expect
      shellHook = ''
        bashdir=$(mktemp -d)
        makeWrapper "$(type -p bash)" "$bashdir/bash" "''${qtWrapperArgs[@]}"
        exec "$bashdir/bash"
      '';
    };
  };
}
