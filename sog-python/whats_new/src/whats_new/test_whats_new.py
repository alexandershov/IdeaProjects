# Tests describing interesting new features from python3.13-python3.15
import sys
import threading
import time
from queue import Queue

import pytest

# lazy imports are exactly what it sounds like:
# at import time they don't actual import, they just create a proxy object
# real import happens when you access module attributes
lazy from . import broken_utils


class Point:
    """Class to showcase __static_attributes__"""
    def __init__(self):
        self.x = 0
        self.y = 0

    def set_distance(self):
        self.distance = (self.x ** 2 + self.y ** 2) ** 0.5


def test_nogil():
    # python 3.13+ has free threaded mode, without GIL
    # in .python_version I use 3.15t - "t" stands for free threaded.
    # if we run this test without GIL (default on free threaded builds)
    # then it'll run in ~0.23s:
    #  uv run pytest -s
    # duration=0.22982674976810813, sys._is_gil_enabled()=False, results={('t2', 149999995000000), ('t1', 49999995000000)}
    # if we run it with gil (PYTHON_GIL=1), then it'll run in ~0.45s.
    # PYTHON_GIL=1 uv run pytest -s
    # duration=0.4559958749450743, sys._is_gil_enabled()=True, results={('t2', 149999995000000), ('t1', 49999995000000)}
    # difference is ~2x which proves that 2 threads are running in parallel
    started_at = time.monotonic()
    queue = Queue()
    t1 = threading.Thread(target=my_sum, args=(range(10_000_000), "t1", queue))
    t2 = threading.Thread(target=my_sum, args=(range(10_000_000, 20_000_000), "t2", queue))
    t1.start()
    t2.start()
    t1.join()
    t2.join()

    duration = time.monotonic() - started_at
    results = {queue.get(), queue.get()}
    print(f"{duration=}, {sys._is_gil_enabled()=}, {results=}")


def test_lazy_import_access():
    # although broken_utils is totally broken (it raises at import time)
    # we'll get an exception only here: at the place of first use
    with pytest.raises(ZeroDivisionError):
        broken_utils.add(8, 9)


def test_frozendict():
    # frozendict is an immutable dictionary
    d = frozendict({'x': 1, 'y': 2})
    with pytest.raises(TypeError):
        # you can't change frozendict
        d['z'] = 3
    # frozendict is not a subclass of dictionary
    assert not isinstance(d, dict)
    # it inherits from object
    assert frozenset.__bases__ == (object,)


def test_static_attributes():
    # __static_attributes__ returns a list of all attributes accessed via self.X in a class definition
    assert set(Point.__static_attributes__) == {'x', 'y', 'distance'}


def my_sum(items, thread_id, queue):
    result = 0
    for an_item in items:
        result += an_item
    queue.put((thread_id, result))
