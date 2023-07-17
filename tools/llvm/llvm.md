## LLVM

LLVM (Low-Level-Virtual-Machine) is a compiler toolchain.

You can generate IR (low-level intermediate language) and LLVM can optimize it
and generate binary.

IR is kind of portable assembler for some abstract machine with infinite number
of registers.

Generate IR with clang

```shell
clang -S -emit-llvm hello.c
```

This will create file [hello.ll](./hello.ll) with a readable IR.

IR can be represented as a human-readable file (with an assembly-like language) or as bytecode or
as an in-memory binary structure.


Install llvm (MacOs)
```shell
brew install llvm
```

We can compile IR file into real assembly language
```shell
/opt/homebrew/opt/llvm/bin/llc hello.ll
```

Now [hello.s](./hello.s) contains assembly code.

Compile, link, and run assembly

```shell
clang hello.s -o hello && ./hello
```
