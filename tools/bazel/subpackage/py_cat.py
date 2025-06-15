import argparse
import contextlib
import itertools


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=argparse.FileType('r'), required=True)
    parser.add_argument('--output', type=argparse.FileType('w'), required=True)
    parser.add_argument('--string-to-append', default='')
    return parser.parse_args()


def main():
    args = parse_args()
    with contextlib.closing(args.input) as input_, contextlib.closing(args.output) as output:
        for line in itertools.chain(input_, [args.string_to_append]):
            print(line, file=output, end="")


if __name__ == '__main__':
    main()
