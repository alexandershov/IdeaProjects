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

### Do we need extra token types for parens/brackets etc?
* ✅Yes
  Probably would be easier for a switch statement
  Tokens are explicitly listed
* 🛑No


### How to implement Tokenizer.next & Tokenizer.peek?
* 🛑matchOf(regex) 
 Maybe regexes should be used, but there's no mature zig regex library, so let's roll out our own stuff 

* ✅ manual
```zig
  switch currentByte {
    '0-9': => readNumber()
    ';': => readSingleLineComment()
    '{': => readMultiLineComment()
    '"': => readString() 
    _ => 
}
```

### How peek & next interact?
* ✅Just inline code, that's not an important decision 

```zig
next(self) {
  result = peek()
  nextToken = null
  return result
}

peek(self) {
  if nextToken == null {
    nextToken = <someCode that reads a token>
  } 
  return nextToken
}
```

### What to do with allocation?
* ✅Accept an allocator in Tokenizer initializer
  This minimizes total interface surface in next/peek, so let's go with it 
* 🛑Accept an allocator in next/peek functions
* 🛑Create the allocator behind the scenes
  this is wrong, since memory should be deallocated somewhere and 
  and Tokenizer goes out of scope, so does the allocator and we got a memory leak
