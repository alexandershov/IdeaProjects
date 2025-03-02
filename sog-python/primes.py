import itertools
from typing import Generator

import pytest


def naive_primes() -> Generator[int, None, None]:
    for x in itertools.count(2):
        for v in range(2, x):
            if x % v == 0:
                break
        else:
            yield x


def primes() -> Generator[int, None, None]:
    generated = [2]
    yield from generated


@pytest.mark.parametrize('n', [10])
def test_primes(n):
    expected = list(itertools.islice(naive_primes(), n))
    actual = list(itertools.islice(primes(), n))
    assert actual == expected
