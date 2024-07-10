import time
# typing module provides types & functions for static type checkers
# two main type checkers are mypy (`pip install mypy`) and pyright (`pip install pyright`)

# pyright is generally faster, does type inference, uses its own parser that can recover from syntax errors
# and has faster development pace (e.g. ** param specs are supported in pyright)
from typing import Callable, assert_type, NewType, Any, Annotated, Concatenate, Protocol, override, TypedDict, \
    assert_never

# Numbers is a type alias, `Numbers` will be tre
type Numbers = list[int]

# NewType creates, ahem, a new type, typechecker will treat it as a subclass of list[int]
Fib = NewType('Fib', list[int])


# **P is a shorthand for ParamSpec, it's used for forwarding parameters
# use P.args, P.kwargs to forward parameters
# Concatenate allows you to add stuff to ParamSpec, e.g. an argument before ParamSpec
def timing[** P, R](fn: Callable[P, R]) -> Callable[Concatenate[int, P], R]:
    def wrapper(x: int, *args: P.args, **kwargs: P.kwargs) -> R:
        start = time.time()
        result = fn(*args, **kwargs)
        # result = fn(1, *args, **kwargs) won't typecheck
        # because 1 is a new parameter
        duration = time.time() - start
        print(f'Function {fn.__name__} took {duration:.3f} seconds')
        return result

    return wrapper


@timing
def add(x, y):
    return x + y


def mul_any(x: Any, y: Any) -> Any:
    # typechecks, because Any is compatible by any type and supports all operations of all types
    return x * y


# def mul_object(x: object, y: object) -> object:
# doesn't typecheck, because object doesn't support `*`
# return x * y


# x will be treated as str by typechecker
# and the rest of arguments to Annotated can be accessed with at runtime with `.__metadata__`
def annotations(x: Annotated[str, {"any": "metadata"}]):
    return x


# Protocol is like interface from Java
class Duck(Protocol):
    def quack(self):
        pass


class Figure:
    def area(self) -> float:
        return 0


class Circle(Figure):
    def __init__(self, radius: float):
        self._radius = radius

    # same as Java override
    @override
    def area(self):
        return self._radius * self._radius * 3.14


def talk_with(duck: Duck):
    duck.quack()


# only typechecks if dict has keys 'name' and 'age' with the specified types
class Person(TypedDict):
    name: str
    age: int


def check_assert_never(x: str | int):
    if isinstance(x, str):
        print('str')
    elif isinstance(x, int):
        print('int')
    else:
        # assert_never asks typechecker to verify that this code is unreachable
        # it raises AssertionError at runtime
        assert_never('unreachable')


def main():
    fib: Numbers = [1, 1, 2, 3, 5, 8]
    assert_type(fib, list[int])
    # assert_type asks typechecker to validate the type
    assert_type(fib[0], int)

    new_fib = Fib([1, 1, 2, 3, 5, 8])
    assert_type(new_fib, Fib)
    # assert_type(new_fib, list[int]) won't typecheck, as typechecker considers Fib and list[int] distinct types
    assert_type(new_fib[0], int)
    print(annotations.__annotations__['x'].__metadata__)
    me: Person = {'name': 'sasa', 'age': 39}
    check_assert_never(8)


if __name__ == '__main__':
    main()
