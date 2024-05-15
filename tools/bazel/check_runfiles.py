import os
import pathlib

import requests


def main():
    # cwd is bazel-out/..../_main
    # _main is ctx.workspace_name, looks like it can't be changed
    print(f'{os.getcwd()=}')
    # cwd contains bazel.md and subpackage/file_in_subpackage.txt
    # also it contains this script itself and bazel python runner
    print(f'{os.listdir()=}')
    assert pathlib.Path('bazel.md').exists()
    assert pathlib.Path('subpackage/file_in_subpackage.txt').exists()


if __name__ == '__main__':
    main()
