# fire is python library to easily create CLI applications
import fire


def main(name: str, *, alias: str = 'haha', loud: bool = False):
    # when you run this function under `fire.Fire` then you'll have this:
    # you can run it from the bash as `python fire_tutorial.py`
    # a required NAME positional arg
    # an optional argument named --alias (or -a) with the default value 'haha'
    # an optional --loud flag with the default value False
    message = f'hello {name}'
    if loud:
        message = message.upper()
    print(message)


class Greeter:
    # fire can work on a class and every method works like a subparser in argparse
    # or you can use a dictionary instead of the class

    def __init__(self, prefix: str = ''):
        # we can pass constructor arguments via CLI
        # python fire_tutorial.py --prefix boom hello sasa
        self._prefix = prefix

    def hello(self, name: str):
        print(f'{self._prefix}hello {name}')

    def shout(self, name: str):
        print(f'{self._prefix}hello {name}'.upper())

    def add(self, x: int, y: int):
        # fire converts arguments to ints
        # (it does that automatically without looking at type hints)
        print(f'{self._prefix}{x + y=}')

    def take(self, s: str, count: str):
        # fire will print the result of a function, no need to print
        # you can call methods the result from the cli
        # `python fire_tutorial.py take name 2 upper` will print 'NA'
        return self._prefix + s[:count]


if __name__ == '__main__':
    # can be used as `python fire_tutorial.py sasa --loud`
    # fire.Fire(main)

    # can be used as `python fire_tutorial.py add 9 10`
    # `python fire_tutorial.py add 9 10 -- completion` will generate
    # a completion script for a shell
    fire.Fire(Greeter)
