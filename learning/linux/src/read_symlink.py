import argparse
import os


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('symlink_path')
    return parser.parse_args()


def main():
    args = parse_args()
    link_to = os.readlink(args.symlink_path)
    # looks like open either always follows symlinks or fails with an error if O_NOFOLLOW is specified
    # fd = os.open(args.symlink_path, os.O_RDONLY | os.O_NOFOLLOW)
    print(link_to)


if __name__ == '__main__':
    main()
