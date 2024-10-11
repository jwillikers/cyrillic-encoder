{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs =
    {
      # deadnix: skip
      self,
      nixpkgs,
      flake-utils,
      pre-commit-hooks,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        nativeBuildInputs = with pkgs; [
          appstream
          appstream-glib
          asciidoctor
          ccache
          clang
          clang-tools
          cmake
          desktop-file-utils
          fish
          flatpak-builder
          gdb
          include-what-you-use
          just
          lcov
          librsvg
          lldb
          llvm
          lychee
          mold-wrapped
          nil
          ninja
          nushell
          python311Packages.lcov-cobertura
          qt6.wrapQtAppsHook
        ];
        buildInputs = with pkgs; [
          boost
          microsoft-gsl
          qt6.qtbase
          qt6.qtwayland
          ut
        ];
        treefmt = {
          config = {
            programs = {
              actionlint.enable = true;
              clang-format.enable = true;
              # todo Upstream support for cmake-format.
              cmake-format.enable = true;
              jsonfmt.enable = true;
              just.enable = true;
              nixfmt.enable = true;
              statix.enable = true;
              taplo.enable = true;
              typos.enable = true;
              yamlfmt.enable = true;
            };
            settings.formatter.typos.excludes = [
              "*.avif"
              "*.bmp"
              "*.gif"
              "*.jpeg"
              "*.jpg"
              "*.png"
              "*.svg"
              "*.tiff"
              "*.webp"
              ".vscode/settings.json"
            ];
            projectRootFile = "flake.nix";
            settings.formatter = {
              "cmake-format" = {
                command = "${pkgs.bash}/bin/bash";
                package = pkgs.cmake-format;
                options = [
                  "-euc"
                  ''
                    for file in "$@"; do
                      ${pkgs.cmake-format}/bin/cmake-format --in-place "$file"
                    done
                  ''
                  "--" # bash swallows the second argument when using -c
                ];
                includes = [
                  "*.cmake"
                  "CMakeLists.txt"
                ];
              };
            };
          };
          options.programs.cmake-format = {
            enable = pkgs.lib.mkEnableOption "cmake-format";
            package = pkgs.lib.mkPackageOption pkgs "cmake-format" { };
          };
        };
        treefmtEval = treefmt-nix.lib.evalModule pkgs treefmt;
        pre-commit = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            check-added-large-files.enable = true;
            check-builtin-literals.enable = true;
            check-case-conflicts.enable = true;
            check-executables-have-shebangs.enable = true;

            # todo Not integrated with Nix?
            check-format = {
              enable = true;
              entry = "${treefmtEval.config.build.wrapper}/bin/treefmt --fail-on-change";
            };

            check-json.enable = true;
            check-shebang-scripts-are-executable.enable = true;
            check-toml.enable = true;
            check-xml.enable = true;
            check-yaml.enable = true;
            deadnix.enable = true;
            detect-private-keys.enable = true;
            editorconfig-checker.enable = true;
            end-of-file-fixer.enable = true;
            fix-byte-order-marker.enable = true;
            flake-checker.enable = true;
            forbid-new-submodules.enable = true;
            # todo Enable lychee when asciidoc is supported.
            # See https://github.com/lycheeverse/lychee/issues/291
            # lychee.enable = true;
            mixed-line-endings.enable = true;
            nil.enable = true;

            strip-location-metadata = {
              name = "Strip location metadata";
              description = "Strip geolocation metadata from image files";
              enable = true;
              entry = "${pkgs.exiftool}/bin/exiftool -duplicates -overwrite_original '-gps*='";
              package = pkgs.exiftool;
              types = [ "image" ];
            };
            trim-trailing-whitespace.enable = true;
            yamllint.enable = true;
          };
        };
      in
      with pkgs;
      {
        devShells.default = mkShell {
          inherit buildInputs;
          inherit (pre-commit) shellHook;
          nativeBuildInputs =
            nativeBuildInputs
            ++ [
              treefmtEval.config.build.wrapper
              # Make formatters available for IDE's.
              (lib.attrValues treefmtEval.config.build.programs)
            ]
            ++ pre-commit.enabledPackages;
        };
        formatter = treefmtEval.config.build.wrapper;
        packages.default = qt6Packages.callPackage ./default.nix { };
      }
    );
}
