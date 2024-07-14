"""
Tests describing interesting new features from python3.9-python3.12
"""
import asyncio
import bisect
import datetime as dt
import graphlib
import itertools
import time
import traceback
import zoneinfo
from dataclasses import dataclass

import pytest


def test_dict_merge():
    x = {'a': 1, 'b': 2}
    y = {'b': 3, 'd': 4}
    # `|` is a concise way to merge dictionaries
    # if key exists in both dictionaries, then last dict take precedence
    assert (x | y) == {'a': 1, 'b': 3, 'd': 4}
    # `|` doesn't modify dicts
    assert x == {'a': 1, 'b': 2}
    assert y == {'b': 3, 'd': 4}
    # you can chain `|`
    assert (x | y | y) == (x | y)
    # `|=` modifies dicts
    x |= y
    time.sleep(90)
    assert x == {'a': 1, 'b': 3, 'd': 4}


def test_datetime():
    # zoneinfo module provides a wrapper around system tzinfo
    # no need for dateutil/pytz
    tz = zoneinfo.ZoneInfo('Europe/Amsterdam')
    now = dt.datetime.now(tz)
    assert now.tzinfo == tz
    # dt.UTC is an alias for dt.timezone.utc
    assert dt.UTC is dt.timezone.utc


def test_graphlib():
    # graphlib expects graph in a format: node -> predecessors
    graph = {'fastapi': ['stdlib', 'starlette'], 'starlette': ['stdlib']}
    # static_order returns topological ordering
    order = list(graphlib.TopologicalSorter(graph).static_order())
    assert order == ['stdlib', 'starlette', 'fastapi']


def sleep_and_return(duration: float, value):
    time.sleep(duration)
    return value


@pytest.mark.asyncio
async def test_asyncio_to_thread():
    # asyncio.to_thread can run blocking function in a separate thread
    # it's nicer interface than run_in_executor
    result = await asyncio.to_thread(sleep_and_return, 0.05, 'some_value')
    assert result == 'some_value'


@pytest.mark.asyncio
async def test_asyncio_timeout():
    with pytest.raises(asyncio.TimeoutError):
        # `timeout` is an async context manager that raises TimeoutError
        # when task doesn't complete in the specified time
        async with asyncio.timeout(0.01):
            await asyncio.sleep(0.05)


@pytest.mark.asyncio
async def test_asyncio_task_group():
    # TaskGroup are like nurseries from trio
    # with them, you can't spawn orphan tasks
    # both tasks will be awaited
    # if one task fails, then TaskGroup will cancel the other one
    async with asyncio.TaskGroup() as tasks:
        first = tasks.create_task(asyncio.sleep(0.01))
        second = tasks.create_task(asyncio.sleep(0.02))
    assert first.done()
    assert second.done()


async def raises(exc):
    raise exc


@pytest.mark.asyncio
async def test_exception_groups():
    try:
        async with asyncio.TaskGroup() as tasks:
            tasks.create_task(raises(ZeroDivisionError))
            tasks.create_task(raises(TypeError))
            tasks.create_task(raises(ValueError))
    # TaskGroup raises an ExceptionGroup that combines several exceptions into one
    # you can handle separate exceptions with `except*`
    # matching exception will be removed from TaskGroup
    # if ExceptionGroup contains any unhandled exception, an exception will be raised
    except* ZeroDivisionError as exc:
        # exc is an ExceptionGroup containing all matching exceptions
        assert isinstance(exc, ExceptionGroup)
        assert len(exc.exceptions) == 1
        assert isinstance(exc.exceptions[0], ZeroDivisionError)
    except* TypeError:
        pass
    except* ValueError:
        pass


@dataclass(frozen=True)
class Person:
    name: str
    age: int


def test_pattern_matching():
    me = Person('sasa', 39)
    match me:
        # we can specify attribute values
        case Person(name, age=39):
            assert name == 'sasa'
            # age is not in scope when we match on it
        case Person(name, age):
            del name  # unused
            del age  # unused
            assert False
        case _:
            # default case
            assert False


# nice syntax to write generic code
def add[T](x: T, y: T) -> T:
    return x + y


def test_typing():
    # `|` is a nicer way to write Union[int, float]
    x: int | float = 1
    y: int | float = 2
    # type checker will infer that z has type `int | float`
    z = add(x, y)
    assert z == 3


def test_itertools():
    # iterate by pairs
    pairs = list(itertools.pairwise([1, 2, 3]))
    assert pairs == [(1, 2), (2, 3)]
    # `pairwise` returns an empty iterator if there's not enough elements
    assert list(itertools.pairwise([1])) == []

    # `batched` returns non-intersecting batches of length n (or less if there's not
    # elements to form batch of length n
    batches = list(itertools.batched([1, 2, 3], 2))
    assert batches == [(1, 2), (3,)]


def test_exceptions():
    try:
        1 / 0
    except ZeroDivisionError as exc:
        # add_note adds some info to exception, that is shown in tracebacks
        exc.add_note('some note')
        assert 'some note' in traceback.format_exc()
        # notes are stored in __notes__ attribute
        assert exc.__notes__ == ['some note']


def test_bisect():
    # bisect supports `key` argument that is applied to every element of list
    i = bisect.bisect(["a", "ab", "abcd"], 3, key=len)
    assert i == 2
