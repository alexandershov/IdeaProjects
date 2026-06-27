# Memory

## Caches
Historically CPU speed and memory bus speed were comparable.
Then starting at 1990s, CPUs became faster & faster. 
Now RAM access can take ~100 CPU cycles. Something must be done to better utilize CPU, 
so it's not waiting on RAM 99% of the time.    

There are two kinds of RAM: SRAM (static) & DRAM (dynamic).
SRAM is much faster, but also much more expensive. SRAM is used to implement caches.
Since SRAM is expensive, this means caches are small. 
E.g. my macbook has 32gb of RAM, and 192kb+128kb of L1 cache (per core).
Why two caches 192kb+128kb? One is for instructions, another is for data, since data & instructions are independent.

Cache greatly helps the code that exhibits temporal & spatial locality.

Spatial locality: if you access memory at location X, then it's highly probable that you access the
location X +/- y (where y is small) in the near time.

Temporal locality: if you access memory at location X, then it's highly probable that you access the
same location again in the near time.

There are actually several levels of caches.
They appeared for the same reason L1 cache appeared: memory is too slow and it was not economically
viable to increase the size of L1 cache. So L2 and L3 appeared.
L1 cache are per-core, higher-level caches are shared between all cores.

All data that CPU reads/writes are going through the cache. 
So CPU doesn't even interact with the main memory directly!
It's actually up to cache machinery to decide when 
(or even `if` in cases when unflushed data is overwritten in cache) data written to a cache should be written to memory 
(as long as logically CPU sees correct data).

Data is written to cache by "lines". Line is usually 64 bytes. You can get actual cache line size with getconf on Linux:
```shell
getconf LEVEL1_DCACHE_LINESIZE
64
```

That was ryzen, interestingly that on M2 Max it's 128 bytes:
```shell
sysctl -n hw.cachelinesize
128
```

When CPU writes data to memory, it actually writes data to cache. 
Until this cache line is written to a real memory, the line is considered "dirty".
Some amount of coordination is needed for multicore systems: since each core have its own independent cache.
This is called cache coherency.

Cache lines are not written as a single operation. It's 64bytes, so it's probably eight of 64bit writes.
Let's say we need a word somewhere in the end of cache line. In a simple case we would wait till this word will
become available. But it's a waste! We need just 1 word, but not only we load the entire line, we also wait till
the last word will become available. So there's critical word optimization when the word we requested can be written first.

## Caches Introspection
We can inspect CPU params by querying /sys/devices/system/cpu/cpu*/cache. It works only on Linux.

Each cpu has its own directory:
```shell
$ ls /sys/devices/system/cpu/ | rg 'cpu\d'
cpu0
cpu1
cpu2
cpu3
cpu4
cpu5
cpu6
cpu7
cpu8
cpu9
cpu10
cpu11
```
It's actually "each thread", because this machine has 6 cpus and 12 threads.

We can introspect caches for each cpu:
```shell
ls /sys/devices/system/cpu/cpu0/cache/
index0  index1  index2  index3 uevent
```
We can see that cpu0 has 4 caches (each index* directory).
index0 is L1d, index1 is L1i, index2 is L3, index3 is L3.

Here's the proof:
```
$ cat /sys/devices/system/cpu/cpu0/cache/index0/type
Data
$ cat /sys/devices/system/cpu/cpu0/cache/index1/type
Instruction
$ cat /sys/devices/system/cpu/cpu0/cache/index0/level
1
$ cat /sys/devices/system/cpu/cpu0/cache/index1/level
1
```

We can see cache sizes:
```shell
cat /sys/devices/system/cpu/cpu0/cache/index*/size
32K
32K
512K
16384K
```

We can see what's the sharing model for each cache:
```shell


cat /sys/devices/system/cpu/cpu0/cache/index*/shared_cpu_list
0,6
0,6
0,6
0-2,6-8
```
cpu0 & cpu6 are two threads of the same core - and they share  `L1[id]` and `L2` caches.
L3 cache for cpu0 is shared across 6 threads (3 cores). Actually ryzen has two L3 caches, each is 16MB,
32MB in total.

## Virtual Memory
See description of virtual memory in [linux.md](../linux/linux.md).
Advantage of virtual memory is that each process sees itself as it the sole user of memory on a machine.
Another advantage that page mapping can map different virtual pages to the same physical pages - this saves physical memory.

Virtual memory is not free performance-wise: page tables are also in memory and the more nested page tables
(and they can be really nested with 4-5 levels) - the more memory accesses you need to translate 
virtual address to a physical address.
And as we remember accessing memory is slow! So another cache is born. It's called TLB (translation lookaside buffer),
and caches VM translations (smth like virtual page X -> physical page Y).

You can make pages bigger to decrease nesting of page tables, but it's not free: e.g. there are different alignment requirements,
where executables need to aligned to a page start, so it's wasteful.

There are different optimizations for TLB cache, e.g. in naive implementation if we switch to another process, then
we would need to purge TLB, this is inefficient, so TLB cache can be additionally tagged with some kind of process id,
so it can persist better.

## NUMA
NUMA stands for Non-Uniform Memory Access. It is based on the fact that each CPU/core can have "local" memory, which is
faster to access from this specific CPU. Note, that "local" doesn't mean tha other CPUs can't access it.
They can, but it will be slower than local access.

## NUMA Introspection

I don't have NUMA on my machine (there's only `node0`)
```shell
ls /sys/devices/system/node/ | rg node
node0
```

In NUMA system there would be several `node*`.
Each node contains distances for different CPUs.

```shell
# imaginary example
cat /sys/devices/system/node/node0/distance
# one cpu has distance 10, other have distance 20. Less distance - faster is access.
10 20 20 20
```

## Programming
### Bypassing cache
Let's say we write data to memory, but we don't plan to use it soon. By default when we write data to memory,
we actually write it to cache. But to write it to cache, we need first to read the cache line into cache!
We just waste cache and evict some useful data.

For this case `_mm_stream_*` intrinsics are provided. 
If you know that you will have non-temporal store (== you won't access this memory location soon) then
`_mm_stream_*` allow you to bypass cache and write directly to memory. These intrinsics work best if memory
locations you're writing to a contigious. In this case several `_mm_stream_` can be executed by CPU in parallel.

For non-temporal reads there's `_mm_stream_load*`, it works similar to its write counterparts with the same
idea of "reads from contigious locations can be executed by CPU".

### Writing data-cache friendly code
See [matmul.cpp](./matmul.cpp) for an example of how doing more work, but making algorithm cache-friendly completely
destroys not-cache-friendly algorithms.

Decrease memory footprint of your structs:
* Avoid holes in your structs, see [alignment.cpp](./alignment.cpp) for a description of alignment rules - e.g. reorder elements of structs.
* Store booleans out of band (e.g. separate array just with bools) instead of bool field in a struct, that will be padded
* more general to storing booleans out of band is struct of arrays instead of array of structs: ECS-like.
  * this way you don't fetch data you won't use, so prefetch and L1 are more effective.
* Handlers (regular u32) instead of points - saves 64bit -> 32bit, but makes your code less typesafe

Decreasing memory footprint makes you to use less cache lines, so L1 is having less evictions and is used more efficiently.
Critical Word Optimization mentioned earlier means that accessing struct elements that are defined first is more performant.
Also accessing struct elements in the order they are defined is more performant!
If your struct is bigger than a cache line, then apply above rules on a level of cache-line sized chunks of the struct,
not the entire struct itself.
Caveat: your struct should be aligned at cache-line size (it's not a default!) for the reorder of elements to have performance (and not just memory footprint) benefits.
You can change alignment of the structure with the __attribute__((aligned(64))) - it works both for struct definitions and for variable definitions.
Caveat #2: different CPUs have different cache line sizes, so don't hardcode 64.


## Sources
* What every programmer should know about memory: https://people.freebsd.org/~lstewart/articles/cpumemory.pdf
* Practical data-oriented design: https://www.youtube.com/watch?v=IroPQ150F6c