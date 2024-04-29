import sys
import unittest

import getpass
import pathlib


class SandboxTest(unittest.TestCase):
    def test_sandbox(self):
        home = pathlib.Path.home()
        print(f"{getpass.getuser()=}")
        print(f"{home=}")

        tmp_read = home / "tmp" / "app.py"
        # reading outside the sandbox directory is allowed
        print(tmp_read.read_text(), file=sys.stderr)

        tmp_write = home / "tmp" / "some_file.txt"
        # tests are running in a sandbox
        # default sandbox is darwin-sandbox/linux-sandbox
        # this sandbox doesn't allow modifying filesystem outside the sandbox directory
        # so write_text will fail when running under
        # bazel test :sandbox_test
        # but will succeed under `bazel run :sandbox_test`
        # when running docker inside the docker then linux-sandbox is unavailable
        # and bazel uses different sandbox (processwrapper-sandbox), that allows writing
        # to filesystem outside the sandbox directory
        # forcing processwrapper-sandbox is hard to do, so here's example using
        # `local` sandbox: `bazel test --spawn_strategy=local :sandbox_test -t-`
        tmp_write.write_text("some content")


if __name__ == '__main__':
    unittest.main()
