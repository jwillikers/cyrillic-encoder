from conans import ConanFile, CMake
import os

class CyrillicEncoder(ConanFile):
    name = "Cyrillic Encoder"
    license = "GPLv3"
    url = "https://github.com/jwillikers/cyrillic-encoder"
    description = " A demo Qt application for encoding alphanumeric characters as arbitrary Cyrillic symbols"
    settings = "arch", "build_type", "compiler", "os"
    generators = "CMakeDeps", "CMakeToolchain"
    requires = "boost/1.77.0", "boost-ext-ut/1.1.8", "icu/69.1", "ms-gsl/3.1.0", "qt/5.15.2"
    default_options = {
        "boost:i18n_backend": "icu",
        "boost:without_stacktrace": True,
    }
    scm = {"type": "git", "url": "auto", "revision": "auto" }
    _cmake = None

    def configure_cmake(self):
        if self._cmake is not None:
            return self._cmake
        self._cmake = CMake(self)
        self._cmake.definitions["CMAKE_TOOLCHAIN_FILE"] = "conan_toolchain.cmake"
        self._cmake.configure()
        return self._cmake

    def build(self):
        cmake = self.configure_cmake()
        cmake.build()

    def package(self):
        cmake = self.configure_cmake()
        cmake.install()

    def package_info(self):
        self.env_info.PATH = os.path.join(self.package_folder, "bin")


