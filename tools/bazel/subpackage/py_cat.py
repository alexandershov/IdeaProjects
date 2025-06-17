import argparse
import contextlib
import itertools
import os


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', type=argparse.FileType('r'), required=True)
    parser.add_argument('--output', type=argparse.FileType('w'), required=True)
    parser.add_argument('--string-to-append', default='')
    return parser.parse_args()


def main():
    # cwd is execroot/_main inside the sandbox, e.g.,
    # /private/var/tmp/_bazel_aershov/aa113e5d9cb7e4bbe0353cfbd569ece8/sandbox/darwin-sandbox/2/execroot/_main
    print(f"{os.getcwd()=}")
    args = parse_args()
    with contextlib.closing(args.input) as input_, contextlib.closing(args.output) as output:
        for line in itertools.chain(input_, [args.string_to_append]):
            print(line, file=output, end="")


if __name__ == '__main__':
    main()
