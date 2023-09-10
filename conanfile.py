import os

from conan import ConanFile
from conan.tools.cmake import cmake_layout, CMake
from conan.tools.files import update_conandata
from conan.tools.scm import Git


class CyrillicEncoder(ConanFile):
    name = "cyrillic-encoder"
    license = "GPL-3.0-or-later"
    url = "https://github.com/jwillikers/cyrillic-encoder"
    description = " A demo Qt application for encoding alphanumeric characters as arbitrary Cyrillic symbols"
    settings = "arch", "build_type", "compiler", "os"
    generators = "CMakeDeps", "CMakeToolchain", "VirtualBuildEnv", "VirtualRunEnv"
    package_type = "application"
    default_options = {
        "boost/*:i18n_backend": "icu",
        "boost/*:without_stacktrace": True,
        "qt/*:qtwayland": True,
    }
    requires = "boost/1.83.0", "boost-ext-ut/1.1.9", "icu/73.2", "ms-gsl/4.0.0", "qt/6.5.2"
    tool_requires = "cmake/[~3.27]", "ninja/[~1]"

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
