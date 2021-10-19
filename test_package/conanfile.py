from conans import ConanFile


class TestPackage(ConanFile):

    def test(self):
        self.run("cyrillic-encoder --version", run_environment=True)
