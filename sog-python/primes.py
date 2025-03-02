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

    # multiplied_generated[j] == primes[j] * some_multiplier (except for multiplied_generated[0], which is ignored)
    # `multiplied_generated` is a relict of times when division was slow
    # so instead of checking that `x` % prime_divisor == 0, we store multipliers of generated primes that can divide x
    # value of multiplied_generated is in the range of (`x` - p; `x` + p)
    # if value == `x`, then x % prime_divisor == 0 (because prime_divisor * some_multiplier == x)
    multiplied_generated = [2]
    # consider only odd numbers as possible primes
    for x in itertools.count(3, step=2):

        while divisors_end < len(generated) and generated[divisors_end] ** 2 <= x:
            divisors_end += 1

        for i in range(1, divisors_end):
            while multiplied_generated[i] < x:
                multiplied_generated[i] += generated[i]
            if multiplied_generated[i] == x:
                # x is not a prime, because it has prime_divisor
                break
        else:
            # x is a prime, because it has no prime divisors
            generated.append(x)

            # if next prime candidate has the smallest divisor that is < `x` then previous multiplied_generated
            # will take care of it
            # if next prime candidate has the smallest divisor == x, then it's okay to start with `x * x`, because
            # this candidate is at least `x * x`
            multiplied_generated.append(x * x)
            yield x


@pytest.mark.parametrize('n', [1000])
def test_primes(n):
    expected = list(itertools.islice(naive_primes(), n))
    actual = list(itertools.islice(primes(), n))
    assert actual == expected
