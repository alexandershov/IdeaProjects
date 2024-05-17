import pathlib


def main():
    assert pathlib.Path('hello.tp').exists()
    assert pathlib.Path('inc.bazel').exists()


if __name__ == '__main__':
    main()
