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

Data is written to cache by "lines". Line is usually 64 bytes.
When CPU writes data to memory, it actually writes data to cache. 
Until this cache line is written to a real memory, the line is considered "dirty".
Some amount of coordination is needed for multicore systems: since each core have its own independent cache.
This is called cache coherency.

Cache lines are not written as a single operation. It's 64bytes, so it's probably eight of 64bit writes.
Let's say we need a word somewhere in the end of cache line. In a simple case we would wait till this word will
become available. But it's a waste! We need just 1 word, but not only we load the entire line, we also wait till
the last word will become available. So there's critical word optimization when the word we requested can be written first.

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

## NUMA
NUMA stands for Non-Uniform Memory Access. It based on a fact that each CPU/core can have "local" memory, which is
faster to access from this specific CPU. Note, that "local" doesn't mean tha other CPUs can't access it.
They can, but it will be slower than local access.

## Sources
* https://people.freebsd.org/~lstewart/articles/cpumemory.pdf