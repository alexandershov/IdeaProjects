import os
from os import O_WRONLY


def main():
    fd = os.open("some_file.txt", O_WRONLY | os.O_CREAT)
    # fd == 3
    print(f"created {fd=}")
    written = os.write(fd, b"hello")
    print(f"written {written} bytes")
    os.close(fd)

    fd = os.open("some_file.txt", os.O_RDONLY)
    new_fd = os.dup(fd)
    # fd == 3, because we closed previous fd == 3
    print(f"opened {fd=}")
    content_3 = os.read(fd, 3)
    print(f"{content_3=}")

    content_2 = os.read(new_fd, 2)
    print(f"{content_2=}")



if __name__ == '__main__':
    main()
