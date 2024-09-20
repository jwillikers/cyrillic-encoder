default: build

alias f := format
alias fmt := format

format:
    just --fmt --unstable

configure build_type="RelWithDebInfo":
    cmake \
        -GNinja \
        -DCMAKE_BUILD_TYPE="{{ build_type }}" \
        -DCMAKE_CXX_CLANG_TIDY=clang-tidy \
        -DCLANG_FORMAT_PROGRAM=clang-format \
        -DCMAKE_LINKER_TYPE=MOLD \
        -B build \
        -S .

build:
    cmake --build build

test: build
    ctest --output-on-failure --test-dir build

all build_type="RelWithDebInfo": (configure build_type) build test

run: build
    build/src/cyrillic-encoder

package:
    nix build

update:
    nix flake update
