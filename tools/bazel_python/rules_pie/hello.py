import sys

# TODO: why next import doesn't work?
# from rules_pie.greeter import hello
from greeter import hello


def main():
    hello(f"python {sys.version}")


if __name__ == '__main__':
    main()
