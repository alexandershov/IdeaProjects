# Prolog

## What is it?
Prolog is a logical programming language.


## Install
Scryer prolog is an experimental prolog implementation. It's written in Rust, so we can just do:
```shell
cargo install --locked scryer-prolog
```

Scryer error messages are pretty rough, e.g.: `error(instantiation_error,instantiation_error(unknown(from_to(n(0),sup)),1))`
but this implementation is recommended by https://www.metalevel.at/prolog/, so that's what I'm using.

## Usage
```shell
# this will read a file and start Prolog top-level
scryer-prolog tutorial.pl
```

In Prolog top-level you can ask questions:
```
?- grandfather(X, Y).
```

Prolog will find answers. If there are several answers, then:
* Space continues search.
* Enter stop the search.

