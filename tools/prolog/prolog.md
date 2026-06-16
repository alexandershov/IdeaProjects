# Prolog

## What is it?
Prolog is a logical programming language.


## Install
scryer prolog is an experimental prolog implementation. It's written in Rust, so we can just do:
```shell
cargo install --locked scryer-prolog
```

## Usage
```shell
# this will read a file and start Prolog top-level
scryer-prolog tutorial.pl
```

In Prolog top-level you can ask questions:
```
?- grandfather(X, Y).
```

Prolog will find answers. If there are several answers then:
* Space continues search.
* Enter stop the search.

