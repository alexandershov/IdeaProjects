import itertools
from typing import Generator


def naive_primes() -> Generator[int, None, None]:
    for x in itertools.count(2):
        for v in range(2, x):
            if x % v == 0:
                break
        else:
            yield x


def main():
    for prime in itertools.islice(naive_primes(), 10):
        print(prime)


if __name__ == '__main__':
    main()
