## Wasm

Wasm (Web Assembly) is a binary format + VM that provides near native performance in browser.

### Install
clang can compile C/C++ to wasm, but to have a support for stdlib the easiest way to go is emscripten:
```shell
brew install emscripten
```

### Compile to Wasm
```shell
emcc test.cpp -O3 -sEXPORTED_FUNCTIONS='["_sum_to_n"]' -sEXPORTED_RUNTIME_METHODS='["cwrap"]' -o vec.js
```

This produces two files: vec.js & vec.wasm. vec.js is js loader/glue for wasm.

### Use in browser
Open [index.html](./index.html), you'll see console.log.
Under the hood it uses cpp vector! It's quite impressive.

There's also WASI standard, kinda like POSIX but for WASM.

### Wat format
Wat is s-exp based format, it's basically another representation of the binary wasm, but human-readable.

You can convert wasm to wat with:
```shell
brew install wabt
wasm2wat vec.wasm -o vec.wat
```



