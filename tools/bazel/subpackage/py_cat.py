import argparse
import contextlib


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=argparse.FileType('r'))
    parser.add_argument('--output', type=argparse.FileType('w'))
    return parser.parse_args()


def main():
    args = parse_args()
    with contextlib.closing(args.input) as input_, contextlib.closing(args.output) as output:
        for line in input_:
            print(line, file=output, end="")


if __name__ == '__main__':
    main()
