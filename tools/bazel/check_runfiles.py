import argparse
import os
import pathlib

import requests
import runfiles


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--rlocationpath', required=True)
    return parser.parse_args()


def main():
    args = parse_args()
    # cwd is bazel-out/..../_main
    # _main is ctx.workspace_name, looks like it can't be changed
    print(f'{os.getcwd()=}')
    # TODO: how does _FindPythonRunfilesRoot work?
    print(f'{runfiles.runfiles._FindPythonRunfilesRoot()=}')
    # cwd contains bazel.md and subpackage/file_in_subpackage.txt
    # also it contains this script itself and bazel python runner
    print(f'{os.listdir()=}')
    assert pathlib.Path('bazel.md').exists()
    assert pathlib.Path('subpackage/file_in_subpackage.txt').exists()
    r = runfiles.Create()
    location = pathlib.Path(r.Rlocation(args.rlocationpath))
    assert location.exists()


if __name__ == '__main__':
    main()
