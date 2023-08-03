## Idris

Idris a programming language with dependent types.

Dependent types is a fancy way of saying that types are first-class objects in
the language. E.g. we can write function that take and return types.

Install Idris
```shell
brew install idris2
```

See [tutorial](./tutorial.idr) for more details.

Run tutorial:
```shell
idris2 tutorial.idr -o tutorial && ./build/exec/tutorial
```