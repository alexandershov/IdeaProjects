## GPU

## What is it?
GPU is Graphics Processing Unit

### How does it work?


GPUs are optimized for throughput instead of latency. This is kinda opposite to CPUs which are optimized for
latency (branch prediction, big caches). 

Single thread on a CPU is smart, single thread on GPU is dumb. But you have bunch of these threads on GPU and 
GPU scheduler is pretty smart (i.e it will replace warps if it's waiting on a memory access).

GPU is divided into a group of Streaming Multiprocessors (SM).
SM is like a core on CPU, only it contains a bunch of cores.

CPU invokes `drawcall`, these are added to a driver's pushbuffer. When pushbuffer contains enough data, 
then work is scheduled.

When a work is scheduled on a GPU it'll run on SM (think shaders). SM operates in warps. Warps is a software concept, 
it's several (32 or 64) threads. All threads in warp execute the same code. If your code contains "if" statement:
```c
1. if (x > 0.5) {
2.   y += 0.1;
3. }
4. x += .1
```

Then threads in a warp on older GPUs will execute in a lock-step: let's say threads A & B are running our code.
in A: x > 0.5, in B: x < 0.5, so while A executes the line 2, thread B does nothing (it's masked out)! It waits at line 4.
When thread A gets to line 4, then thread B will also execute it. This means that if you have a divergent flows
in your shaders, then GPU will not use it's cores efficiently: lots of threads will be masked out and will do nothing.

Memory latency on GPU is high, so if warp is waiting on memory it can be swapped by another warp.
But memory throuput on GPU is great! Like I said: GPUs are optimized for throughput instead of latency.
Memory locality also works for GPUs: memory is a grid (row/column), so if you access memory row by row, then you're golden.