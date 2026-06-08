# Erlang

## What is it?
Erlang is a functional programming language. It contains a lot of building blocks for creating 
reliable distributed systems.

Although Erlang itself is quite slow, it cares about latency: 
e.g. there's no global GC, but there's per-process GC, so there are no big GC pauses.  

## Install
```shell
brew install erlang
```

## Usage
```shell
erlc tutorial.erl && erl -noshell -s tutorial main
```

## Live shell
You can connect to running program.

```shell
erlc tutorial.erl && erl -noshell -s tutorial main -sname myapp -setcookie secret
```

Then in another terminal:
```shell
erl -sname debug -setcookie secret -remsh myapp
```

That's it! You are connected to another process and can e.g. call some functions defined:
```shell
(myapp@Mac)1> tutorial:sum(3, 2).
5
```