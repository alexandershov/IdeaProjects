import mmap


def main():
    with open("src/mmap_example.py") as fileobj:
        m = mmap.mmap(fileobj.fileno(), 0, access=mmap.ACCESS_READ)
        print(f"{m[:10]=}")
        print(f"{m.size()=}")



if __name__ == '__main__':
    main()