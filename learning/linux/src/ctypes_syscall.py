import ctypes
import os


def main():
    # Define the syscall number for getpid
    SYS_getpid = 172  # This is specific to Linux arm64 architecture

    # Define the syscall function using ctypes
    libc = ctypes.CDLL(None)  # Load the standard C library
    syscall = libc.syscall  # Get the syscall function

    # Call the syscall with the number for getpid
    pid = syscall(SYS_getpid)

    # Print the result
    print(f"Process ID (using syscall): {pid}")
    print(f"Process ID (using os.getpid()): {os.getpid()}")


if __name__ == '__main__':
    main()
