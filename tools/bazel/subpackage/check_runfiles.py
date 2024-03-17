import os
import pathlib


# this is the same as check_runfiles.py in the root package
# relative locations of bazel.md and file_in_subpackage.txt are the same
def main():
    # cwd is bazel-out/..../_main
    # _main is ctx.workspace_name, looks like it can't be changed
    print(f'{os.getcwd()=}')
    # cwd contains bazel.md and subpackage/file_in_subpackage.txt
    # {cwd}/subpackage contains this script itself and bazel python runner
    print(f'{os.listdir()=}')
    assert pathlib.Path('bazel.md').exists()
    assert pathlib.Path('subpackage/file_in_subpackage.txt').exists()


if __name__ == '__main__':
    main()
