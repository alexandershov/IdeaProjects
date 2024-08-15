## Linux

### Run Linux on Mac M2

I tried apple-silicon version of virtual box is 7.0.8beta, it didn't work.

[UTM](https://mac.getutm.app) and ubuntu 24.04 for ARM worked with some tweaks:

* Error "Display Output is not active" is fixed by choosing virtio-ramfb-gl (GPU Supported) option
* Some parts of keyboard were not working when Ubuntu asked for a username during installation.
  What worked for me was choosing keyboard setup during ubuntu installation, then
  ubuntu selected I_dont_remember_WITH_DEAD_KEYS and keyboard started working.
* After installation was completed, I needed to remove ISO from VM settings and start the VM again.

To share a directory, execute this inside of VM:

```shell
sudo mkdir [mount point]
$ sudo mount -t 9p -o trans=virtio share [mount point] -oversion=9p2000.L
```

Or add this line to `/etc/fstab` and reboot VM:

```text
share	[mount point]	9p	trans=virtio,version=9p2000.L,rw,_netdev,nofail	0	0
```


### System calls
User programs interact with kernel using system calls (aka syscalls). System calls is essentially an API provided by OS.
Each syscall has a number (id). E.g., mmap has number [9](https://github.com/torvalds/linux/blob/6b0f8db921abf0520081d779876d3a41069dab95/arch/x86/entry/syscalls/syscall_64.tbl#L21).
Kernel stores syscalls in a table (I guess it's an array indexable by syscall number).

When you call e.g. `read` from you code, you don't call kernel code directly. You're calling C wrapper.
Syscalls in the kernel expect their arguments in registers not in a stack. Wrapper sets these registers and also sets
syscall number in a register, and then calls interrupt (or SYSCALL instruction on linux 2.5+). This interrupt is handled by the kernel which then
finds syscall by its number, does some validation 
(e.g. that process provided valid memory pointers, that are not accessing memory that process shouldn't access)
and then runs the code. Syscall executes in a kernel mode. 
Syscall returns an integer. If it's negative (there are some exceptions to this rule), then syscall finished with an error.
C wrapper then sets negated syscall_return_value in errno. This makes errno positive.

Syscalls have overhead compared to a simple function call,
because we have to interrupt, copy registers, and switch to kernel mode.


### File permissions

```shell
root@ba902351e8af:/# ls -l /bin/ | head -3
total 20284
-rwxr-xr-x 1 root root     43184 Feb  7  2022 [
-rwxr-xr-x 1 root root     10400 Feb 21  2022 addpart
```

first `root` is file owner.
second `root` is group that owns a file.

`r` stands for Read permissions
`w` stands for Write permissions
`x` stands for eXecute permissions.

Permissions are split into 3 groups: owner, group, and everybody else.
`-` is overloaded. `-` as a first character means that it's a file.
But `-` in other places means that someone don't have this permission.

Permissions string format
is `[object_type][owner_read_permission][owner_write_permission][owner_execute_permission][group_read_permission][group_write_permission][group_execute_permission][others_read_permission][other_write_permission][other_execute_permission]`

So `-rwxr-xr-x` means that it's a file, owner can do everything, group and others can read and execute.

So permission 0644 means (underscores are just for readability) `110_100_100` or `rw-r--r--`.

### Proc filesystem

In `/proc/{pid}` you can see a bunch of useful info about the process with `pid`.

E.g.

* `cmdline` that was used to start a process.
* `environ` contains environment variables

### Debugging

`dstat` shows you disk & network usage.

`strace` prints every syscall that your program uses.


Run example of using strace with `make strace-run`:
```shell
make strace-run
<bunch of syscalls>
brk(NULL)                               = 0xadeaa4902000
brk(0xadeaa4923000)                     = 0xadeaa4923000
write(1, "hello world\n", 12)           = 12
exit_group(0)                           = ?
```

`strace -e brk,open` will show you only `brk` and `open` syscalls
`strace -f` will also trace child subprocesses.
`strace -p <pid>` can attach to an existing pid.
`strace -y` will resolve file descriptors to file names.
`strace -s <size>` sets a limit to string size in output. It's 32 by default. So if you need more, then specify
e.g. `-s 1000`.

strace significantly slows down your program.

ebpf allows you to run user code in the kernel. 

E.g. `opensnoop` can show you all open files of a process without a significant performance penalty.
Install it with `sudo apt install libbpf-tools`

And then just run `opensnoop` and it will show you which processes open which files.

There is bunch of similar programs [here](https://github.com/iovisor/bcc?tab=readme-ov-file)
E.g. there is `exitsnoop` that shows all processes that exit.

`perf` allows you to profile programs.

`sudo perf record <your_program>` and `sudo perf report perf.dat` to show the report. 
Report is not working on my VM, I got some menu with no data.

`sudo perf top` shows you TOP for all C functions running on your machine. Very cool.

You can also show generic information about a run with e.g. `sudo perf stat ls`.
You'll get number of context switches, page faults, etc.