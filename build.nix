{ stdenv
, qtbase
, full
, cmake
, wrapQtAppsHook
}:
stdenv.mkDerivation {
  pname = "cyrillic-encoder";
  version = "1.0";

  # The QtQuick project we created with Qt Creator's project wizard is here
  src = ./.;

  buildInputs = [
    qtbase
    full
  ];

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];
