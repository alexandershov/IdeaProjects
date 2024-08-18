import argparse
import sys
import time


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=argparse.FileType("r"), default=sys.stdin)
    return parser.parse_args()


def main():
    args = parse_args()
    while line := args.input.readline():
        if line[:4] == "exit":
            print("exiting")
            return
        print(f"got line length = {len(line)}")
        time.sleep(1)


if __name__ == '__main__':
    main()
