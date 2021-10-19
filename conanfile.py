from conans import ConanFile
from conan.tools.cmake import CMake
import os


class CyrillicEncoder(ConanFile):
    name = "cyrillic-encoder"
    license = "GPLv3"
    url = "https://github.com/jwillikers/cyrillic-encoder"
    description = " A demo Qt application for encoding alphanumeric characters as arbitrary Cyrillic symbols"
    settings = "arch", "build_type", "compiler", "os"
    generators = "CMakeDeps", "CMakeToolchain", "VirtualRunEnv"
    requires = "boost/1.77.0", "boost-ext-ut/1.1.8", "icu/69.1", "ms-gsl/3.1.0", "qt/5.15.2@qtwayland/testing"
    default_options = {
        "boost:i18n_backend": "icu",
        "boost:without_stacktrace": True,
        "qt:qtwayland": True,
    }
    scm = {"type": "git", "url": "auto", "revision": "auto", }

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
        self.env_info.PATH = os.path.join(self.package_folder, "bin")


