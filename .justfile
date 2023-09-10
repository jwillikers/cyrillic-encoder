set shell := ["nu", "-c"]

default: build

# Install dependencies with Conan.
conan-install *flags="--build cascade --build outdated --update":
    #!/usr/bin/env nu
    ^conan install . {{ flags }}

alias con := conan-install
alias conan := conan-install

# Configure CMake.
configure preset="relwithdebinfo":
    #!/usr/bin/env nu
    let build_directory = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get configurePresets } | flatten | where name == "{{ preset }}" | first | get binaryDir)
    ^bash -c $'. ($build_directory)/generators/conanbuild.sh && cmake --preset {{ preset }}'

alias c := configure

# Build the given target.
build preset="relwithdebinfo" target="all":
    #!/usr/bin/env nu
    let build_directory = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get configurePresets } | flatten | where name == "{{ preset }}" | first | get binaryDir)
    ^bash -c $'. ($build_directory)/generators/conanbuild.sh && cmake --build --preset {{ preset }} --target {{ target }}'

alias b := build

# Run the application.
run preset="relwithdebinfo" *flags="": (build preset)
    #!/usr/bin/env nu
    let build_directory = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get configurePresets } | flatten | where name == "{{ preset }}" | first | get binaryDir)
    ^bash -c $'. ($build_directory)/generators/conanrun.sh && ($build_directory)/src/cyrillic-encoder {{ flags }}'

alias r := run

# Run unit tests with CTest.
test preset="relwithdebinfo" *flags="--output-on-failure":
    #!/usr/bin/env nu
    let build_directory = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get configurePresets } | flatten | where name == "{{ preset }}" | first | get binaryDir)
    ^bash -c $'. ($build_directory)/generators/conanbuild.sh && . ($build_directory)/generators/conanrun.sh && ctest {{ flags }} --preset {{ preset }}'

alias t := test

# Build the clean target.
clean preset="relwithdebinfo": (build preset "clean")

# Remove the CMake cache.
rm-cmake-cache preset="relwithdebinfo":
    #!/usr/bin/env nu
    let build_directory = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get configurePresets } | flatten | where name == "{{ preset }}" | first | get binaryDir)
    rm -f ($build_directory | path join CMakeCache.txt)

# Wipe away the build directory.
purge preset="relwithdebinfo":
    #!/usr/bin/env nu
    let build_directory = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get configurePresets } | flatten | where name == "{{ preset }}" | first | get binaryDir)
    rm -rf $build_directory

# Perform each of the necessary build commands in sequence.
full-build preset="relwithdebinfo": (conan-install) (configure preset) (build preset)

alias f := full-build

# Perform each of the necessary build commands in sequence after wiping away the build directory.
clean-build preset="relwithdebinfo": (purge preset) (full-build preset)

alias cb := clean-build
