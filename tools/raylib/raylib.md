# Raylib

## What is it?
Raylib is a library to simplify graphics programming.
More details are [here](https://github.com/raysan5/raylib).


## Install
```shell
brew install raylib
```

## Usage
For parallax and aerial perspective run:
```shell
make parallax_aerial_perspective
```
See [parallax_aerial_perspective.c](parallax_aerial_perspective.c) for more details.


For vignette run:
```shell
make vignette
```

See [vignette.c](vignette.c) for more details.


## Generating trees with L-systems

Trees are kinda recursive structures - they repeat both on micro & macro level.
Grammars are defined by a set of productions:
```text
A -> AB
B -> b
```
Here rule `A` produces `AB` and rule `B` produces `b` (lowercase means that it's terminal).

So given the string `A` in the beginning we'll get a sequence:
`A -> AB -> ABb -> ABbb -> etc`
L-systems are grammars where applying of productions is done in parallel.
Grammars can be deterministic & non-deterministic (when several rules can be applied, so we choose one rule 
at random)

Let's take a grammar:
```shell
A -> AB
B -> A
```

Starting with `A` we'll get a sequence
`A -> AB -> ABA -> ABAAB -> ABAABABA -> ...`
This sequence grows with the same rate as Fibonacci sequence, in fact F(n) = F(n-1) + F(n-2), where + is string concatenation.

The way to transform produced sequences into something visual is to consider each item in a resulting string a
turtle graphics command (like "move forward and draw", "turn left/right X degrees").

These simple rules will allow to draw shapes without lifting a "pencil".
To bypass this limitation we can invent special characters `[` and `]` that act as a stack:
`[` pushes the current position on a stack, and `]` restores the position from the top of the stack.
Other than this `[` and `]` behave exactly the same as ordinary alphabet for a grammar.