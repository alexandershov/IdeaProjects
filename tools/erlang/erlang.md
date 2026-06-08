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
erlc tutorial.erl && erl -noshell -s tutorial main -s init stop
```