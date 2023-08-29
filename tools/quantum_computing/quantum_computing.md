## Quantum Computing

1. Quantum system can be in two states simultaneously. It's called superposition.
2. Quantum systems can be in a somewhat weirdly connected state,
   when changes in one part of the system affect another and vice versa.
   This is called entanglement.

These two phenomenons are used in quantum computing.

Instead of a `bit` in classical computing we have a `qubit`. It's a bit in superposition.
We can describe a qubit as a 2d-vector a|0>, b|1>. `a` and `b` are called probability amplitudes, they can be negative.
Qubit a|0>, b|1> has probability == a^2 to be zero and probability == b ^ 2 to be one.

When we measure qubit will be either 0 or 1. But qubit state between measurements
is on a spectrum between 0 and 1.

Quantum state is kinda exponential.
Hence, quantum algorithms can do exponential-in-classical-computing algorithms really fast.

Quantum algorithms can factor integers in O(log(n)^x) time (Shor's algorithms)
and search a database without indexes in O(sqrt(N)) (Grover's algorithm).