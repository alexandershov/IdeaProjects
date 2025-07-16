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
    # _FindPythonRunfilesRoot() just walks 4 levels up from the __file__
    # it works because runfiles.py is located in
    # check_runfiles.runfiles/rules_python++pip+python_main_hub_311_bazel_runfiles/site-packages/runfiles/runfiles.py
    # rules_py patches _FindPythonRunfilesRoot to walk 6 (because of the venv) levels up from the __file__
    # patch was done here: https://github.com/aspect-build/rules_py/pull/519
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
