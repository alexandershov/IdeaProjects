import os
import time

import fastapi
import runfiles

def main():
    # bazel-bin/web/cmd is a bash binary
    # bazel-bin/web/cmd.runfiles are runfiles
    # bazel-bin/web/cmd executes bazel-bin/web/cmd.runfiles/_main/web/cmd.py
    # there's bazel-bin/web/cmd.runfiles/_main/web/files/data.txt
    # that's why the approach with os.path.join finds the data.txt during the runtime
    path = os.path.join(os.path.dirname(__file__), "files/data.txt")
    with open(path) as fileobj:
        print(fileobj.read())

    # force runfiles to use directory strategy
    del os.environ["RUNFILES_MANIFEST_FILE"]

    # runfiles libraries can resolve runfiles paths
    r = runfiles.Runfiles.Create()
    # there are two strategies: directory (runfiles tree of symlinks) & manifest
    print(f"{r._strategy=}")
    # we pass _main/{path in a repo} to Rlocation
    rlocation = r.Rlocation("_main/web/files/data.txt")
    print(f"{rlocation=}")
    with open(rlocation) as fileobj:
        print(fileobj.read())
    print("sleeping")
    time.sleep(900)


if __name__ == '__main__':
    main()
