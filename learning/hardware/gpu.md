## GPU

## What is it?
GPU is Graphics Processing Unit

### How does it work?


GPUs are optimized for throughput instead of latency. This is kinda opposite to CPUs which are optimized for
latency (branch prediction, big caches). 

Single thread on a CPU is smart, single thread on GPU is dumb. But you have bunch of these threads on GPU.

GPU is divided into a group of Streaming Multiprocessors (SM).
SM is like a core on CPU, only it contains a bunch of cores.

When a work is scheduled on a GPU it'll run on SM. SM operates in warps. Warps is a software concept, 
it's 32/64 threads. All threads in warp execute the same code. If your code contains "if" statement:
```c
1. if (x > 0.5) {
2.   y += 0.1;
3. }
4. x += .1
```

Then threads in a warp on older GPUs will execute in a lock-step: let's say threads A & B are running our code.
in A: x > 0.5, in B: x < 0.5, so while A executes the line 2, thread B does nothing! It waits at line 4.
When thread A gets to line 4, then thread B will also execute it.