import argparse
import sys
from pathlib import Path


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("pid", type=int)
    return parser.parse_args()


def main():
    args = parse_args()
    # remote exec allows executing scripts in another python process
    sys.remote_exec(args.pid, Path(__file__).parent / "script_for_remote_exec.py")
    # uv run src/whats_new/work.py
    # pid=55805
    # in another terminal (sudo or 'com.apple.system-task-port' entitlement are required):
    # sudo uv run src/whats_new/remote_debugging.py 55805

    # previous terminal prints
    # hello via remote_exec

if __name__ == '__main__':
    main()