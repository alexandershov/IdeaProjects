import pathlib


def main():
    # TODO: make it find data files
    assert pathlib.Path('hello.tp').exists()
    assert pathlib.Path('inc.bazel').exists()


if __name__ == '__main__':
    main()
