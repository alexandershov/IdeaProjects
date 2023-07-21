import pprint

import toml


def main():
    with open('toml_tutorial.toml') as fileobj:
        pprint.pprint(toml.load(fileobj))


if __name__ == '__main__':
    main()
