{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
         let
          overlays = [];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          nativeBuildInputs = with pkgs; [
            ccache
            clang
            clang-tools
            cmake
            fish
            gdb
            include-what-you-use
            just
            lldb
            llvm
            mold-wrapped
            ninja
            qt6.wrapQtAppsHook
          ];
          buildInputs = with pkgs; [
            boost
            microsoft-gsl
            qt6.qtbase
            qt6.qtwayland
            ut
          ];
        in
        with pkgs;
        {
          packages.default = qt6Packages.callPackage ./default.nix {};
          devShells.default = mkShell {
            inherit buildInputs nativeBuildInputs;
          };
        }
      );
}
