## Consistency models

These consistency models describe single-value object (e.g. key in KV store)
Things like "Read Committed", "Serializable" are for transactions, not single-value objects. 

#### Linearizability
CAP theorem calls this Consistency.
Basically this implies total order on all the events as if they were executed sequentially.
And if we observe Y, then we can't observe X (X < Y in total order) after Y. 
Intuitively a system with the linearizability property behaves as a variable in a
single-threaded program. You always read the current value. If you write something to 
it, then the read coming _after that_ write will return the new value.
Reads concurrent with this write can return any value (old or new) though.
But if you've read value R1, then all subsequent reads can't go back to R0.

#### Causality
If event A happened before event B, then everybody will observe A before B.
Order B, A is impossible.
"before" have nothing to do with physical clocks, it means that B depends on A.
We can have 3 options for events X and Y:
1. X happened before Y
2. Y happened before X
3. X and Y are concurrent.

#### Read your writes
Process did a write W. All reads happening after that should contain W.

#### Monotonic reads
If R2 is happened after R1 then R2 should be at least as recent as R1 and can't go back to R0.

#### Monotonic writes
If W2 is happened after W1, then all processes will observe W2 after W1.
And order W2, W1 is impossible

#### Eventual consistency
If we stop writes, then eventually we'll get current values during reads.
E.g Init=0, W=3, R=0, R=0, ..., eventually we'll get R=3.