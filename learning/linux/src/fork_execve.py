import os


def main():
    if os.fork() == 0:
        # child
        # noinspection PyUnreachableCode
        result = os.execve("/usr/bin/ls", argv=["."], env={})
        print(f"execve result {result=}")
        print("we'll never get here, because execve doesn't return")
    print("parent exits")


if __name__ == '__main__':
    main()
