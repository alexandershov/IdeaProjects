# TLA+

## What is it?
TLA+ (Temporal Logic and Actions) is a formal specification language used to verify programs.
Mostly distributed systems. Leslie Lamport is the creator of TLA+.

The main idea is this:
* Current state is described by a bunch of variables
* State transitions are described by actions that change values of variables (A -> A', B -> B', etc)
* State & transition descriptions are boolean formulas and can use math.

See [main.tla](./main.tla) for an example of TLA spec.


## Install
```shell
curl -OL https://github.com/tlaplus/tlaplus/releases/download/v1.8.0/tla2tools.jar
```

## Usage
```shell
java -jar tla2tools.jar main.tla
```