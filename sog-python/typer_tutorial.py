import enum

from typing_extensions import Annotated
import typer
import rich

# typer is a fastapi for cli apps
# install it as `pip install "typer[all]"'
# it will include rich - library for a better output in a terminal
# typer is similar to fire
# https://github.com/alexandershov/IdeaProjects/blob/main/sog-python/fire_tutorial.py
# but is more explicit and uses type annotations


app = typer.Typer()


@enum.unique
class Color(enum.Enum):
    RED = 'red'
    GREEN = 'green'
    BLUE = 'blue'


# commands are like subparsers in argparse
@app.command()
def hello(name: str):
    print(f'hello {name}')


# run it as python typer_tutorial.py add 9 8

# THIS DOESN'T WORK: python typer_tutorial.py add --x 9 --y 8
# x and y are positional arguments in the command line
@app.command()
def add(x: int, y: int):
    print(x + y)


# default arguments become options (--y in this example)
# boolean default can be passed as --double (for True) or --no-double (for False)
# color is enum, and it works as expected
# you can make an option using Annotated[type, typer.Option()]
# now --z is a required option
@app.command()
def default_add(x: int, z: Annotated[int, typer.Option()], double: bool = False, y: int = 1,
                color: Color = Color.RED.value):
    result = x + y + z
    if double:
        result *= 2
    # rich supports colors
    rich.print(f'[{color.value}]{result}[/{color.value}]')


# multiple values are supported via lists
# python3 typer_tutorial.py add-all 8 9 10
@app.command()
def add_all(xs: list[int]):
    print(sum(xs))


if __name__ == '__main__':
    # run cli with subcommands
    app()
    # run single command
    # typer.run(hello)
