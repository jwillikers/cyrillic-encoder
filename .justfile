set shell := ["nu", "-c"]

default: build

# Install dependencies with Conan.
conan-install *flags="--build missing --update":
    #!/usr/bin/env nu
    ^conan install . {{ flags }}

alias con := conan-install
alias conan := conan-install

# Configure CMake.
configure preset="conan-default":
    #!/usr/bin/env nu
    let build_directory = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get configurePresets } | flatten | where name == "{{ preset }}" | first | get binaryDir)
    ^bash -c $'. ($build_directory)/generators/conanbuild.sh && cmake --preset {{ preset }}'

alias c := configure

# Build the given target.
build preset="conan-relwithdebinfo" target="all":
    #!/usr/bin/env nu
    let configure_preset = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get buildPresets } | flatten | where name == "{{ preset }}" | first | get configurePreset)
    let build_directory = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get configurePresets } | flatten | where name == $configure_preset | first | get binaryDir)
    ^bash -c $'. ($build_directory)/generators/conanbuild.sh && cmake --build --preset {{ preset }} --target {{ target }}'

alias b := build

# Run the application.
run preset="conan-relwithdebinfo" *flags="": (build preset)
    #!/usr/bin/env nu
    let configure_preset = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get buildPresets } | flatten | where name == "{{ preset }}" | first | get configurePreset)
    let configuration = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get buildPresets } | flatten | where name == "{{ preset }}" | first | get configuration)
    let build_directory = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get configurePresets } | flatten | where name == $configure_preset | first | get binaryDir)
    ^bash -c $'. ($build_directory)/generators/conanrun.sh && ($build_directory)/src/($configuration)/cyrillic-encoder {{ flags }}'

alias r := run

# Run unit tests with CTest.
test preset="conan-relwithdebinfo" *flags="--output-on-failure":
    #!/usr/bin/env nu
    let configure_preset = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get testPresets } | flatten | where name == "{{ preset }}" | first | get configurePreset)
    let build_directory = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get configurePresets } | flatten | where name == $configure_preset | first | get binaryDir)
    ^bash -c $'. ($build_directory)/generators/conanbuild.sh && . ($build_directory)/generators/conanrun.sh && ctest {{ flags }} --preset {{ preset }}'

alias t := test

# Build the clean target.
clean preset="conan-relwithdebinfo": (build preset "clean")

# Remove the CMake cache.
rm-cmake-cache preset="conan-relwithdebinfo":
    #!/usr/bin/env nu
    let build_directory = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get configurePresets } | flatten | where name == "{{ preset }}" | first | get binaryDir)
    rm -f ($build_directory | path join CMakeCache.txt)

# Wipe away the build directory.
purge preset="conan-relwithdebinfo":
    #!/usr/bin/env nu
    let build_directory = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get configurePresets } | flatten | where name == "{{ preset }}" | first | get binaryDir)
    rm -rf $build_directory

# Perform each of the necessary build commands in sequence.
full-build preset="conan-default": (conan-install) && (build preset)
    #!/usr/bin/env nu
    let configure_preset = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get buildPresets } | flatten | where name == "{{ preset }}" | first | get configurePreset)
    let build_directory = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get configurePresets } | flatten | where name == $configure_preset | first | get binaryDir)
    ^bash -c $'. ($build_directory)/generators/conanbuild.sh && cmake --preset ($configure_preset)'

alias f := full-build

# Perform each of the necessary build commands in sequence after wiping away the build directory.
clean-build preset="conan-default": && (full-build preset)
    #!/usr/bin/env nu
    let configure_preset = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get buildPresets } | flatten | where name == "{{ preset }}" | first | get configurePreset)
    let build_directory = ((open CMakeUserPresets.json | get include) | each {|x| open $x | get configurePresets } | flatten | where name == $configure_preset | first | get binaryDir)
    rm -rf $build_directory

alias cb := clean-build

alias u := update
alias up := update

update:
    #!/usr/bin/env nu
    ^pre-commit autoupdate
    ^conan lock create . --lockfile-clean --update
