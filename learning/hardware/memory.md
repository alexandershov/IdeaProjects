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

## Sources
* https://people.freebsd.org/~lstewart/articles/cpumemory.pdf