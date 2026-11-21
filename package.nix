{
  boost,
  cmake,
  microsoft-gsl,
  mold,
  ninja,
  qtbase,
  qtwayland,
  stdenv,
  ut,
  wrapQtAppsHook,
}:
stdenv.mkDerivation {
  pname = "cyrillic-encoder";
  version = "0.0.1";

  src = ./.;

  buildInputs = [
    boost
    microsoft-gsl
    qtbase
    qtwayland
    ut
  ];

  nativeBuildInputs = [
    cmake
    mold
    ninja
    wrapQtAppsHook
  ];

  cmakeFlags = [
    "--preset=minimal"
    "-DCMAKE_LINKER_TYPE=MOLD"
  ];
}
