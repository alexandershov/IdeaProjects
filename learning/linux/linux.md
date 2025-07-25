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

There's `syscall` function in standard C library. You can call any syscall with it.
It takes a `syscall` number. You can call it from python using `ctypes`:

```shell
python3 src/ctypes_syscall.py
```


### File system
Inode is a metadata for a file (type, owner, group, permissions, pointers to data blocks of the file etc).
Inode doesn't contain file name.

File is a stream of bytes.

Work with file system inside of the kernel is done in OOP fashion: there are interfaces (done via function pointers), that
a new file system implementation should provide.

You can see inode number with `ls -li`
Directories store mapping from a filename to its inode. 

How directory is stored exactly - that's the job of a file system implementation.
It can be just a list.

Two entries from different directories can point to the same inode.
This inode will have its attribute link_count == 2.
These are called hardlinks.
Hardlinks can't cross filesystem boundary, because inode is specific to a filesystem.
Also hardlinks can't point to a directory.
Symlinks don't have these limitation.

When link_count == 0 and file is not open, then the physical file gets deleted.
If file is open somewhere then even with `link_count == 0` it won't get deleted immediately.
When you close it, then it'll be deleted.
This behaviour is used by `tmpfile`-like functions: they can create file, open it, and immediately
call `unlink` to it, setting link_count == 0. But the file won't get deleted, because it's open.
Only when you explicitly close this file, or it's closed implicitly (when program exits), then the file will be
deleted.

What `rm` does is:
* deleting path entry from directory
* decrementing link_count for the corresponding inode.

With `mv` you don't move files content, you just update directory content. So it's fast.

Symlinks are a special kind of file, symlink target is actually the content of a symlink file.
There's a syscall readlink that resolves symlink.
Also, you can see that size of `symlink_to_linux.md` is 8 bytes, because `len('linux.md') == 8`
Unfortunately regular open/read can't directly read symlink content. You'll need to use readlink for that.
See [read_symlink.py](src/read_symlink.py) for an example.


Directories are a special kind of file, unfortunately there's no easy way to read a raw (binary) directory content containing a list of files.
For a failed attempt to do that, see [read_raw_dir.py](src/read_raw_dir.py) script.

So you'll need to use opendir/readdir instead of regular open/read

`readdir` returns directory entries. 

Main linux syscalls that operate on file descriptors are:
* open (returns fd)
* read/write/close (obvious names)

Example of syscalls in action:
```shell
python3 src/io_syscall.py
```

`dup` clones a file descriptor.
It'll return a new file descriptor number (with `dup2` you can control the return value)
There's a table of open files in kernel, after dup both file descriptors will share the same kernel entry.
So reading from one fd will affect what you'll see reading from the second fd.
See `src/io_syscall.py` for an example. Also after `fork` you'll get essentially duplicated file descriptors of your parent
in a child process.

There are kernel buffer caches, so when you just call write, nothing actually gets written to a physical file,
kernel uses all available memory for buffer caches. To write stuff to disk you need `fsync` it.

`read` will read from a buffer cache, if there's something in it.
Obviously, buffer cache won't survive reboot.

C stdlib provides its own buffering scheme to save on number of syscalls. You can call fflush to flush
all C stdio buffers to kernel.

If you write to a terminal, then everything is flushed after a newline.
stderr (in C, not in Python!) is always flushed after write.
In python 3.7+ stderr is also line-buffered.
Other than that, you need a manual flush.

You can inspect this behavior in Python with: 
```shell
python3 src/user_space_buffering.py
```

You can make stdout/stderr unbuffered with `-u` in python.

You can view process open files with `lsof`:
```shell
lsof -p <pid>
```

You can also see fds of the process in a `/proc/<pid>/fd`

You can access proc file system of the current process with `/proc/self`.

There's a special file `/dev/stdin` that refers to stdin of the current process
(it's actually a symlink to `/proc/self/fd/0` which is a symlink to `/proc/<pid>/fd/0`)
With `/dev/stdin` you don't need `-` trick to specify stdin as a file name, you can just pass `/dev/stdin`.

This will compare stdin to some file
```shell
diff /dev/stdin linux.md
```

There's `inotify` API in a kernel, that allows you to watch changes in files/directories.

Pipe IO is buffered, newlines don't flush, so you need a manual flush.

If reader is too slow, then writing to a pipe will block. 
Pipe has a buffer of 65kb.
When a reading process terminates, and you have an open pipe, then you'll get SIGPIPE in a writing process.

Check it all with
```shell
python3 src/pipe_writer.py | python3 src/pipe_reader.py
```

You can also create named pipes in a filesystem, they work as the normal pipes, they just have a name in fs,
so you can use it for IPC of two processes that were started in different shells.

Example:
```shell
mkfifo /tmp/my_pipe
python3 src/pipe_writer.py --output /tmp/my_pipe

# in another shell
python3 src/pipe_reader.py --input /tmp/my_pipe
```

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

There's also `setuid` permission bit, when you run a binary with setuid, then it'll run as if a file owner
runs it.

For example `sudo` command has `setuid` bit set (`s` in permissions):
```shell
ls -l /usr/bin/sudo
-rwsr-xr-x 1 root root 335120 Apr  8 14:50 /usr/bin/sudo
```

In older versions of Linux `ping` also required `setuid` to use raw sockets, now it replaced with capabilities:

No suid:
```shell
ls -l /usr/bin/ping
-rwxr-xr-x 1 root root 146984 Apr 23 09:52 /usr/bin/ping
```

Capabilities:
```shell
getcap /usr/bin/ping
/usr/bin/ping cap_net_raw=ep
```


### Proc filesystem

In `/proc/{pid}` you can see a bunch of useful info about the process with `pid`.

E.g.

* `cmdline` that was used to start a process.
* `environ` contains environment variables

### Processes & threads
You can copy a current process with `fork` system call. 
It will create a full copy of the current process. 
From now on you'll have 2 process running the same program.
In the current process `fork` will return pid of the child.
In the child `fork` will return 0.

Run example with
```shell
$ python3 src/fork.py

before fork in parent pid=2882
after fork in parent child_pid=2883
before fork in parent pid=2882
after fork in child child_pid=2883
```

There's no 100% guarantee which process (original process or child) will run first after fork.
In vast majority of cases (> 99.5%) it will be parent, but if parent timeslice is finished exactly after fork,
then child will run first.

Check it with
```shell
make fork-run-10000-times | grep 'in child'
```

You'll need some form of IPC (e.g. signals) if you need strict guarantees on who runs first.

If parent terminates before child, then child becomes orphan: `init` becomes child's parent.
If we call `os.getppid()` from child after parent terminated, then `os.getppid()` will be == 1.

Check it with 
```shell
$ python3 src/orphan.py
in parent pid=53461
in parent pid=53461
in child child_pid=53462 parent_pid=53461
in child child_pid=53462 parent_pid=1
```

If child terminates and parent doesn't call `wait` on it, then child becomes a zombie.
Zombie isn't running (because there's nothing left to run, the child terminated after all), but kernel keeps bookkeeping
information on it. You can't kill zombie with `kill`.
When parent calls `wait` on it, then kernel will remove this bookkeeping information.
If parent terminates without calling `wait`, then `init` process will take care of it.

Zombie demo:
```shell
python3 src/zombie.py
```
Then do `ps aux | grep <child_pid>`. You'll that although child has exited, it's still in the output of ps.
And it has status `Z` (for zombie). When a parent finishes its wait for a child, then child is not in ps output anymore.
If you kill parent before it has waited for a child, then `init` will take over zombie.

Just having fork is not enough, since with fork you can only create a copy of the process.
You can start a new program with one of the `exec*` functions family. It replaces current program text and memory
and runs specified binary. `exec*` functions support shebang (`#!`).
When you run `exec*` it doesn't return, because your program text is getting replaced by a new program.

So a common idiom of running a new subprocess is first running `fork` and then running `execve` in a child branch.
Run example of it with (notice that there's no line "execve result .*" in the output, because `execve` never returns)
```shell
$ python3 src/fork_execve.py
parent exits
Makefile
execve.txt
linux.md
src
symlink_to_linux.md
```

After execve a new process gets the same file descriptors as the original process. So if you redirected stdin/stdout/stderr,
then a new process will see these changes. That's how shell redirects work.

There's `vfork` that's a dangerous alternative to `fork`. 
`vfork` doesn't copy page tables, so they're shared.
Child runs first after `vfork` and it should call `exec*` immediately.
There's no safe way of calling `vfork` in Python, since you can't call only `exec*` in Python with `os.execve`
you'll implicitly call some memory-changing code, because it's Python, not C.

`fork` and `vfork` are actually implemented with `clone` system call. 
`clone` allows you to specify what you want to share between processes. You can share virtual memory and pids,
and you'll get threads this way. In linux there's actually very little differences between threads and processes.
Both threads and processes are just some schedulable entities with different degrees of sharing.

There are two types of time for a process:
* real time: wall clock time of a process
* cpu time: how much time cpu was working, cpu time further divided into
  * system time: how much time cpu was working in kernel
  * user time: how time cpu was working in user mode

If we just sleep, then only real time will be >> zero
```shell
time sleep 1
real = 1s
user ~ 0s
sys ~ 0s
```

If we just crunch numbers, then real time will be == user time. system time will be ~ 0
```shell
time python3 -c 'sum(range(100_000_000))'
real = 1.14s
user = 1.13s
sys = 0.007s 
```

If we add memory allocations (with `list`), then system time will increase, because you need some syscalls to allocate memory.
```shell
time python3 -c 'sum(list(range(10_000_000)))'
real = 0.252s
user = 0.182s
sys =  0.069s
```

### Process scheduling
Simplest possible scheduling algorithm is:
* Select some process to run
* Give it timeslice (say, 10ms) and run it
* When timeslice is finished or process yields CPU (whatever comes first) because of e.g. IO, select another process to run etc ...

This is the most naive and simple approach and the problem with this if you have CPU-intensive application and
IO-bound (interactive) application, then CPU-intensive application can hog CPU for the whole timeslice and
your interactive application will have latency.

So CFS (Completely Fair Scheduler) was added to Linux. 
If you have N runnable (runnable == process is ready to run, it's not waiting on anything) processes, then it's expected that each process will get 1/N share of CPU.
There are still time slices (1ms), because it's inefficient to run process for an infinitely small amount of time
(because of context switching overhead).

Example:
* We have two processes.
* Each is expected to get 50% of CPU.
* Interactive process runs and almost immediately waits for some IO (network/keyboard/etc). It used almost 0% of CPU.
* CPU intensive process runs for some time
* IO happened, interactive process is runnable, since it used almost 0% of CPU and was promised 50% it runs as soon as 
  timeslice of CPU process ends.
* Rinse/repeat.
* This way everyone is happy: CPU intensive process actually gets almost all the CPU, but interactive process
  runs with minimal latency (1ms) then some events occur.

CFS was replaced in 2023 by [EEVDF scheduler](https://en.wikipedia.org/wiki/Earliest_eligible_virtual_deadline_first_scheduling).
EEVFD improves on latency for latency-sensitive processes. 
There's a [lwn article](https://lwn.net/Articles/925371/) explaining how EEVFD works.

### Virtual memory
Each process has its own memory address space. This is called virtual memory.
CPU expects its memory operands to be a in a real physical memory.
This means that virtual memory addresses need to be converted to physical memory addresses.

This is done with page tables.
The following page table example uses 32-bit architecture for simplicity. 64-bit is a bit more complicated, but the 
main principles are similar.
There's a piece of hardware called MMU (Memory Management Unit) that can translate virtual addresses to physical addresses.
Both virtual and physical memory are split in 4KB chunks. These chunks are called pages.
Since we're on a 32-bit architecture, this means we have 2^32 memory addresses.
4KB = 4096 = 2^12
2^32 = 2^12 * 2^20. We have 2^20 pages.

Logically page table is a mapping of each virtual page (2^20 in total) to a physical page (2^20 in total).
Naive implementation of it would be an array of 2^20 integers. This is 2^20 * 4 = ~4MB.
It's pretty rare for a process to use all of its pages, so creating this array is wasteful.
So a tree-like structure is used. 

We have a root array of 2^10 integers. Each element points to a leaf (possibly non-existing) array of 2^10 elements.
Each element in a leaf array points to a physical page.

Given 32-bit virtual address `[10 bit][10 bit][12 bit]` we take first 10 bits and locate entry in the root array.
Entry in a root array points to a leaf array. We can locate entry in a leaf array using second 10 bits of the virtual bit address.
Now we have a physical page, and we just append last 12 bit of virtual address to it getting physical address.
Each leaf array is conveniently 4KB, so root array elements can use just first 20 bits to point to it.
Since we have just 2^20 pages, leaf array elements also can use just first 20 bits to point to it.
The rest 12 bits are used for flags (read-only, etc).
This approach although is more complicated then naive array of 2^20 elements is way more efficient in memory usage.
Virtual memory often has a bunch of large unused intervals 
(e.g. interval between heap and stack will be unused for not memory-hungry programs).
Each leaf array can represent 2^10 pages = 2^10 * 2^12 bytes == 2^22 bytes. That's about 4MB of memory that is
represented by 2^10 * 4 bytes = 4KB of page table data.
We always pay 4KB for a root array, that's pretty small price.
E.g. if we use only first 30 and last 30 root array entries then we can represent
4MB * (30 + 30) = 240 MB of data.
We pay the price of 4KB (root array) + (30 + 30) * 4KB = 61 * 4KB = 240KB. That's pretty small. 

When process tries to access unmapped virtual address, then page fault is generated and we're getting
infamous "Segmentation Fault" and crash.

When we fork process we can just copy its page tables (maybe we can even share them, but looks like linux doesn't do this)
and don't touch physical memory. 
Then when child modifies its memory we can copy only affected pages. This is called copy on write.

When we have context switch between process, we also switch their page tables.

### Process memory layout
From lower to higher addresses:
* Text segment (contains code)
* Static & global variables
* Heap
* Stack (grows downwards on most architectures)
* Environ
* Kernel


Empirical proof:
```shell
$ make memory-run
0xbc9b667f08d4 = code address
0xbc9b66810014 = static address
0xbc9b6d9872a0 = heap address
0xffffececdd9c = stack address depth 1
0xffffececdd74 = stack address depth 2
0xffffececdf48 = environ address
```

As we can see different between heap and stack is (0xffffececdd9c - 0xbc9b6d9872a0 == 74098912029436 =~ 69TB)
Also interesting fact that maximum address is ~2^48, so not all the 64 bits are available by default.

There's a syscall named `brk` that can increase available heap memory (essentially it sets an end of heap).
When you do `brk` you only increase virtual memory. Physical memory is not increased. Only when you write
something to this virtual memory then you'll use physical memory (RSS in `top`).
On a C level you use malloc and free to get a new memory, malloc uses brk under the hood.
malloc and free are ordinary functions, not syscalls!

When you `free` memory then you'll rarely see decrease in RSS/virtual memory usage, because most freed block
will be somewhere in the middle of the heap. And free can reduce brk only when the freed block is the last one.


### Mmap
You can use `mmap` system call. It gives you an illusion that file is a block of memory.
You can access `mmap` object as if it is a bytearray fully loaded in memory , and kernel will load it from the disk
on demand. You can open huge files with mmap, and only memory that you accessed will be resident.
If bunch of processes `mmap` the same file, then kernel will share physical memory representing the file between processes.

mmap demo:
```shell
python3 src/mmap_example.py
```

Dynamic linking uses mmap, so a popular shared library is loaded into physical memory only once.

Instead of a file descriptor can pass -1 to `mmap`, and it will create anonymous mmap, that you can share
with a child.

### Linking
You can have dynamic and static linking.
With static linking, you add all library dependencies inline to your binary.
With dynamic linking, you use shared libraries.
With shared libraries, you essentially say: "I want to use library X at the runtime".
OS will look for library X at runtime at some predefined paths.

With shared libraries you can save disk space, RAM (because one shared library can be used by a bunch of programs
and you can load it into physical RAM only once and then let virtual memory do the job, similar to program text).
But you start depending on the presence of the library in a system. 
So it's a tradeoff.

You can see which shared libraries a binary uses with `ldd`.

Static linking example:
```shell
$ make static-linking-run
go build -o src/static src/static.go && (ldd src/static || true)
  not a dynamic executable
```

Dynamic linking example:
```shell
$ make dynamic-linking-run
gcc -o src/hello src/hello.c && ldd src/hello
	linux-vdso.so.1 (0x0000fc4c80ca0000)
	libc.so.6 => /lib/aarch64-linux-gnu/libc.so.6 (0x0000fc4c80a80000)
	/lib/ld-linux-aarch64.so.1 (0x0000fc4c80c63000)
```

### Systemd
Systemd is a:
* `init` process replacement: it has pid == 1, and manages other processes
* syslog replacement (with journald/journalctl)
* everything else replacement

### Apt
There are `apt-get`, `apt-cache`, and `apt` commands.

`apt` kinda replaces `apt-get` and `apt-cache`. E.g. you can't search with `apt-get`, you need `apt-cache` for that.
`apt` can install packages as well as search for them:
```shell
apt search sbcl
apt show sbcl
apt install sbcl
```

List installed packages:
```shell
apt list --installed
```

List packages that can be upgraded:
```shell
apt list --upgradable
```

Overall `apt` provides a nicer interface that `apt-get` + `apt-cache`.
There's a limitation though: output of `apt` is not guaranteed 
to be stable, so if you need to parse output of `apt`, then you should use `apt-get`.


### Terminals
Terminals were real physical devices used to communicate with computers.
Nowadays there are no more physical terminals. 
There are terminal emulators that emulate these physical devices.
Terminal can work in canonical mode (line-oriented with line editing, like shell) or in non-canonical mode (character-oriented, like vi)

There's also special file `/dev/tty` that represents current process terminal.
This terminal is not affected by e.g. stdin/stdout redirects.

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