import os

from conan import ConanFile
from conan.tools.cmake import cmake_layout, CMake, CMakeDeps, CMakeToolchain
from conan.tools.env import VirtualBuildEnv, VirtualRunEnv
from conan.tools.files import update_conandata
from conan.tools.scm import Git


class CyrillicEncoder(ConanFile):
    name = "cyrillic-encoder"
    license = "GPL-3.0-or-later"
    url = "https://github.com/jwillikers/cyrillic-encoder"
    description = " A demo Qt application for encoding alphanumeric characters as arbitrary Cyrillic symbols"
    settings = "arch", "build_type", "compiler", "os"
    package_type = "application"
    default_options = {
        "boost/*:header_only": True,
        "qt/*:openssl": False,
        "qt/*:qtwayland": True,
        "qt/*:with_md4c": False,
        "qt/*:with_odbc": False,
        "qt/*:with_pq": False,
        "qt/*:with_sqlite3": False,
    }

    def requirements(self):
        self.requires("boost/1.83.0")
        # Override conflict.
        self.requires("icu/73.2")
        self.requires("ms-gsl/4.0.0")
        self.requires("qt/6.5.2")

    def build_requirements(self):
        self.test_requires("boost-ext-ut/1.1.9")
        self.tool_requires("cmake/[~3.27]")
        self.tool_requires("ninja/[~1]")

    def layout(self):
        cmake_layout(self)

    def export(self):
        git = Git(self, self.recipe_folder)
        scm_url, scm_commit = git.get_url_and_commit()
        update_conandata(self, {"sources": {"commit": scm_commit, "url": scm_url}})

    def source(self):
        git = Git(self)
        sources = self.conan_data["sources"]
        git.fetch_commit(sources["url"], sources["commit"])

    def generate(self):
        # Load system fonts via fontconfig.
        self.runenv.define("FONTCONFIG_FILE", "/etc/fonts/fonts.conf")
        self.runenv.define("FONTCONFIG_PATH", "/etc/fonts")

        virtual_build_env = VirtualBuildEnv(self)
        virtual_build_env.generate()

        virtual_run_env = VirtualRunEnv(self)
        virtual_run_env.generate()

        cmake_deps = CMakeDeps(self)
        cmake_deps.generate()

        tc = CMakeToolchain(self)
        tc.generate()

    def build(self):
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        cmake = CMake(self)
        cmake.install()

    def package_info(self):
        self.cpp_info.libs = []
        self.cpp_info.includedirs = []
        self.env_info.PATH.append(os.path.join(self.package_folder, "bin"))
