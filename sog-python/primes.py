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
    # `generated` contains all primes generated so far
    generated = [2]
    yield from generated

    # we consider each odd `x` as a candidate to a prime
    # if x is not prime then it has some prime divisor
    # the smallest prime divisor of `x` is <= sqrt(x)
    # so we need to consider only primes p <= sqrt(x)
    # this is equivalent to p**2 <= x
    # `divisors_end` is the first index in `generated` such that p**2 > x
    # if there's no such an element, then divisors_end == len(generated)
    divisors_end = len(generated)
    # consider only odd numbers as possible primes
    for x in itertools.count(3, step=2):

        while divisors_end < len(generated) and generated[divisors_end] ** 2 <= x:
            divisors_end += 1

        # consider only odd primes as possible divisors, because x is odd
        for prime_divisor in itertools.islice(generated, 1, divisors_end):
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
