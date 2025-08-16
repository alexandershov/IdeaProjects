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

### How buffered reader is implemented?
We need at least `toss(usize)` and `peek([]u8)`.
Can we implement `readWhile()` using these? Let's try:
```zig
pub fn readWhile(allocator: Allocator, reader: *BufferedReader, allowedChars: []u8, stopChars: []u8) []u8 {
  var list = std.ArrayList(u8).init(allocator);
  while (true) {
    const nextChar: [1]u8 = undefined;
    try reader.peek(nextChar)
    const canContinue = (nextChar[0] in allowedChars) and (nextChar[0] not in stopChars)
    if (!canContinue) break
    reader.toss(1)
    list.append(nextChar[0])
  }
  return list.items
}
```

Turns out, yes we can.
Now what's the implementation of `toss(usize)` & `peek([]u8)`
```zig

/// circular buffer
/// start == end means empty
/// but how's full buffer is represented
/// given [a, b, c] how to represent b, c, a
/// [a, b, c]
///     ^
///     s
/// start & size
buffer []u8;
start usize;
end usize;
reader Reader;

pub fn peek(peekaboo []u8) {
  assert buf.len >= peekaboo.len
  if size >= peekaboo.len {
     // we need to possibly handle circular thing here
     memcpy(buffer, peekaboo) 
  } else {
    // possibly handle circular thing here 
    memcpy(reader.read(len_difference), buf + start)
  }
}

pub fn toss(n usize) {
  // assert size >= n
  start = (start + n) % buf.len
  size -= n
}
```

### Current implementation of `peek` is incredibly ugly. How to improve on it?
We need to do 2 tasks in `peek`:
1. possibly reading missing bytes into `self.buffer`
1. filling `out` from `self.buffer`

What if we had a magic function rangesFrom()?
```zig
const Range = struct {
  start: usize,
  end: usize,
}

fn rangesFrom(self: *Self, start usize, len usize) []Range {
  
}
```

We can use this function both for getting ranges to copy from `self.buffer` to `out`.
And we can use it to fill out `self.buffer` (start would be self.start + self.usize)

Can we do it easier?
Let's say we work in a linear way and do the transformation at the very end

abcd
  ^
buffer.len = 4
start = 2, offset = 0, len = 3, should be `[cd]` + `[a]`
we're getting end = 2 + 3 = 5. range is `[2, 5]`. 5 is out of bounds
So we split it with `[2, 4]` & `[4, 5]` and we simply translate `[4, 5]` to `[0, 1]`.

start = 2, offset = 3, len = 1, should be [`b`]
range is `[5, 6]` we just translate it to `[1, 2]`

abcd|ab
     4 6