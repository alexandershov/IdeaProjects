import argparse
import os
import signal
import sys
import time


def on_sigpipe(_signum, _frame):
    print("got SIGPIPE", file=sys.stderr)

signal.signal(signal.SIGPIPE, on_sigpipe)

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=argparse.FileType("w"), default=sys.stdout)
    return parser.parse_args()


def main():
    args = parse_args()
    i = 0
    while True:
        if i == 3:
            content = b"exit\n"
        else:
            content = b"x" * 1024 * 30 + b"\n"
        i += 1
        written = os.write(args.output.fileno(), content)
        print(f"[{i}] written {written} bytes", file=sys.stderr)
        time.sleep(0.05)


if __name__ == '__main__':
    main()
