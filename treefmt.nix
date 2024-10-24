{
  pkgs,
  ...
}:
{
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
    projectRootFile = "flake.nix";
    settings.formatter = {
      typos.excludes = [
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
}
