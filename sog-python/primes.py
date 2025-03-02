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
    divisor_end = len(generated)
    yield from generated
    for x in itertools.count(3, step=2):

        while divisor_end < len(generated) and generated[divisor_end] ** 2 <= x:
            divisor_end += 1

        for prime_divisor in itertools.islice(generated, 1, divisor_end):
            if x % prime_divisor == 0:
                break
        else:
            generated.append(x)
            yield x


@pytest.mark.parametrize('n', [10])
def test_primes(n):
    expected = list(itertools.islice(naive_primes(), n))
    actual = list(itertools.islice(primes(), n))
    assert actual == expected
