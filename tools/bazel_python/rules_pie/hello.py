import sys

from rules_pie.greeter import hello


def main():
    hello(f"python {sys.version}")


if __name__ == '__main__':
    main()
