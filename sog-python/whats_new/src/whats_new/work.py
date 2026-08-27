import os
import time


def main():
    pid = os.getpid()
    print(f"{pid=}")
    for _ in range(10000):
        time.sleep(0.1)
        work()


def work() -> int:
    return sum(1 for _ in range(100_000_000))


if __name__ == '__main__':
    main()
