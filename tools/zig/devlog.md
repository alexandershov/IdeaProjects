## 2025-08-08

### Possible approaches:
* ✅Tokenize and Parse
* 🛑No tokenize
  seems hacky and implementation will be harder
```zig
  pub fn parsePgn(reader) {
    while (!eof) {
        parseGame()
    }  
}
```

## 2025-08-09

### How to implement tokenizer:
* 🛑Regexes
  Easier to implement 
  Not fun
* ✅Manual with FSM
  Full control
  More educational
  
### Tokenizer interface
* ✅Iterator
```zig
next() !?Token
peek() !?Token
```
Nice and idiomatic
* 🛑Parse into array of tokens
  We can parse multigb files, that can be wasteful

### Parser interface
* ✅ Iterator
```zig
const Parser = struct {
   tokenizer: Tokenizer
   next() !?Game
}
```

### Do we need extra token types for parens/brackets etc
* ✅Yes
  Probably would be easier for a switch statement
  Tokens are explicitly listed
* 🛑No