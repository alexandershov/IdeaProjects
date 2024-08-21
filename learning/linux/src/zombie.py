import os
import time


def main():
    fork_result = os.fork()
    if fork_result == 0:
        # child
        print("[child] exiting")
    else:
        child_pid = fork_result
        print(f"[parent] {child_pid=}")
        time.sleep(60)
        os.waitpid(child_pid, 0)



if __name__ == '__main__':
    main()