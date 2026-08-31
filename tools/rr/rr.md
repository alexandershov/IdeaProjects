# rr

## What is it?
rr is deterministic debugger that can record & replay program execution. 


## Install
```shell
sudo apt install rr
sudo apt install gdb
```

## Usage
Change content of `/proc/sys/kernel/perf_event_paranoid` to 1 - so `rr` can use `perf_event_open` API.

My CPU is Ryzen, so we need to do Zen workaround:  
```shell
git clone https://github.com/rr-debugger/rr.git
sudo python3 rr/scripts/zen_workaround.py
```

[debug.c](./debug.c) is a program that intentionally crashes under random circumstances.
To debug it we can: run a program under `rr record` in a loop to repro crash.
rr records traces: information required to deterministically replay your program later.
Deterministically means that EVERYTHING will be the same during replay: memory addresses, registers, 
syscalls will return the same data.

Then we do `rr replay` on a saved trace.

Let's compile our program with the debugging information:
```shell
clang debug.c -O0 -g -o debug
```

Let's repro our bug:
```shell
python3 repro.py
```

Now let's replay:
```shell
rr replay ./rr_trace
# run till crash
(rr) continue
Continuing.
ts.tv_nsec = 83424561

Program received signal SIGSEGV, Segmentation fault.
0x000056ed325261cb in main () at debug.c:16
16	    (*p) = 10;
(rr)
# let's watch changes to the value of variable crash
(rr) watch -l crash
Hardware watchpoint 1: -location crash
# and now let's do reverse continue: we'll execute our program in reverse!
# and we'll wee when `crash` was changed! pretty damn cool.
(rr) reverse-cont
Continuing.

Hardware watchpoint 1: -location crash

Old value = 487
New value = 486
0x000056ed325261a7 in main () at debug.c:11
11	    crash++;
# we see that we got to crash++ line
# tv_sec is even
(rr) p ts.tv_sec
$1 = 41999402
(rr) reverse-cont
```

So `rr` is super useful to debug non-deterministic failures - because you have deterministic replay and you can
go forward & backward in time.
