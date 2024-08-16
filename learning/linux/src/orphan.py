import os
import time


def main():
    pid = os.getpid()
    print(f"in parent {pid=}")
    if os.fork() == 0:
        child_pid = os.getpid()
        parent_pid = os.getppid()
        time.sleep(1)
        print(f"in child {child_pid=} {parent_pid=}")
        time.sleep(1)
        # parent is dead at this moment
        # child becomes an orphan, and `init` process (pid = 1) becomes our parent
        parent_pid = os.getppid()
        print(f"in child {child_pid=} {parent_pid=}")
    else:
        time.sleep(0.5)


if __name__ == '__main__':
    main()
