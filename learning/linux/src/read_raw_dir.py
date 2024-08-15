import argparse
import os


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('dir_path')
    return parser.parse_args()


def main():
    args = parse_args()
    fd = os.open(args.dir_path, os.O_RDONLY | os.O_DIRECTORY)
    # os.read will fail with "is a directory"
    content = os.read(fd, 1024)
    print(content)


if __name__ == '__main__':
    main()
