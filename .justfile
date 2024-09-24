default: build

alias f := format
alias fmt := format

format: just-fmt clang-format

clang-format:
    clang-format -i include/cyrillic-encoder/*.hpp src/*.cpp

just-fmt:
    just --fmt --unstable

alias c := configure

configure preset="dev":
    cmake --preset {{ preset }} -DCMAKE_LINKER_TYPE=MOLD

alias b := build

build preset="dev" target="all":
    cmake --build --preset {{ preset }} --target {{ target }}

alias t := test

test preset="dev": build
    ctest --preset {{ preset }}

alias w := workflow

workflow preset="dev" *flags="":
    cmake --workflow --preset {{ preset }} {{ flags }}

alias r := run

# todo Parse build directory from preset.
run preset="dev": (build preset)
    build/src/cyrillic-encoder

alias d := debug

# todo Parse build directory from preset.
debug preset="dev" debugger="gdb": (build preset)
    {{ debugger }} build/src/cyrillic-encoder

alias p := package
alias pack := package

package:
    nix build

alias u := update
alias up := package

update:
    nix flake update
