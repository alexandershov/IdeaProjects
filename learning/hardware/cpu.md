## CPU

Let's say 1 instruction takes 4 cycles to execute. If CPU naively goes through one instruction by another
then throughput for e.g. 100 cycles would be 25 instructions. 
So throughput is 0.25 instructions/cycle and latency for a single instruction is 4 cycles. 
Throughput can be optimized.

### Pipelining
Each instruction goes through Fetch, Decode, Execute, Writeback (write result) phases.
If we'll have a dedicated parts of CPU to do:
* Fetch
* Decode
* Execute
* Writeback

Then we can execute 4 instructions (i1, i2, i3, i4) at the same time: 
* clock 1: i1 Fetch
* clock 2: i1 Decode, i2 Fetch
* clock 3: i1 Execute, i2 Decode, i3 Fetch
* clock 4: i1 Writeback, i2 Execute, i3 Decode, i4 Fetch
* clock 5: i2 Writeback, i3 Execute, i4 Decode, i5 Fetch
* clock 6: i3 Writeback, i4 Execute, i5 Decode, i6 Fetch
* clock 7: i4 Writeback, i5 Execute, i6 Decode, i7 Fetch
* clock 8: i5 Writeback, i6 Execute, i7 Decode, i8 Fetch
....
Each instruction latency stays the same: 4 cycles. But starting with clock 4 we complete 1 instruction.
So throughput (ignoring first 3 clocks when pipeline ramps up) is 1 instruction/cycle.
Deeper pipelines are possible, but we can't increase the pipeline ad infinitum, because it'll have 
diminishing returns (instructions depend on each other, so there's a natural limit on how many instructions
one can run in parallel).

CPUs theoretical throughput is higher than real-world programs allow, 
because of the dependencies between instructions, memory accesses etc.
So pipeline elements are often underused. Hyperthreading is a way to use these underused elements.
If you have several threads then same pipeline can execute elements from instructions from different threads.
E.g. we have 2 threads. Decode #1 is not busy, because thread #1 is underusing CPU. So decode from thread #2 
can be executed on Decode #1.

Dependant instructions actually don't need to wait for Writeback of another instruction.
There are "bypasses" - kinda like speed lanes where instructions can feed their results to another instructions
before Writeback finishes.

### Superscalar
We can have 2 Fetchers, 2 Decoders etc. This will double our throughput. This is superscalar architecture:
when we have several units for each task.

### Out of order execution
If CPU will try to execute instructions in order, then there will be problem because instructions depend on
each other stalling pipeline. So CPU can try out of order execution to keep pipeline saturated.
Actually compiler can do that too. Compiler knows more about a program structure, but CPU knows more about 
the runtime (e.g. cache misses)

### Speculative execution (branch prediction)
Branches destroy naive pipeline architecture, because we don't know what the next instruction will be.
That's why CPU tries to guess which branch will be taken. Surprisingly it can guess pretty well 
with 90%+ accuracy. This is called branch prediction.

### Cache
CPU is much faster than RAM. Fetch from RAM on the order of magnitude of 100 cycles.
That's why CPU employs caches: L1, L2, L3.
L1 is the fastest cache, but also the smallest.
Cache-friendly algorithms access memory in 
* predictable fashion (e.g. iterating over an array, i, i+1, i+2, ...)
* using all the data that was fetched: struct of arrays over array of structs.

Cache greatly helps the code that exhibits temporal & spatial locality.
Temporal locality: if you access memory at location X, then it's highly probable that you access the
same location again in the near time.

Spatial locality: if you access memory at location X, then it's highly probable that you access the 
location X +/- y (where y is small) in the near time.

When we write to a memory that cache is invalidated.
Memory is cached in terms of cache lines (64 bytes), not single words. 
There's also a prefetcher that predicts at what address memory will be accessed next. 
Prefetcher can update cache based on this.


