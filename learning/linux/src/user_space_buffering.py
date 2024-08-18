import sys
import time

def main():
    # "stdout hello" will appear only after flush/program termination, because there's no newline
    print("stdout hello", end="\t")
    # will appear immediately as it's flushed
    print("flushed stderr hello", end="\t", file=sys.stderr, flush=True)
    # "stderr hello" will appear only after flush/program termination, because there's no newline
    # and in python stderr behaves exactly as stdout
    print("stderr hello", end="\t", file=sys.stderr)

    time.sleep(1)


if __name__ == '__main__':
    main()
