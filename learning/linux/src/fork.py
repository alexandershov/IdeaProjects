import os


def main():
    pid = os.getpid()
    print(f"before fork in parent {pid=}")
    fork_result = os.fork()
    if fork_result == 0:
        # child
        child_pid = os.getpid()
        print(f"after fork in child {child_pid=}")
    else:
        # original process
        child_pid = fork_result
        print(f"after fork in parent {child_pid=}")


if __name__ == '__main__':
    main()