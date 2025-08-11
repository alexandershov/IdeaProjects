/// Parse PGN files
/// This is just parsing and skips moves validation
const std = @import("std");

// pgn format spec:
// comments: ; till the end of string and {} comments
// line starting with % should be ignored

/// Represent a token in PGN file
/// E.g. [Event "Live Chess"] will be tokenized into
/// * .OpeningBracket("[")
/// * .Whitespace(" ")
/// * .Text("Event")
/// * .String("Live Chess")
/// * .ClosingBracket("]")
const Token = union(enum) {
    /// Delimits PGN tags
    OpeningBracket: u8,
    ClosingBracket: u8,

    /// Delimits (possibly recursive) variations
    OpeningParen: u8,
    ClosingParen: u8,

    /// Represents move numbers
    Number: u32,

    /// Comments can be of two types:
    /// ; single line comment follows semicolon
    /// { comment inside of the braces }
    Comment: []u8,

    /// Includes spaces, tabs, newlines
    Whitespace: []u8,

    /// Represents tag values
    String: []u8,

    /// Represents period e.g after a white move number `1. e4`
    /// or one of the periods after a black move number `1... e5`
    /// `...` is represented as three consequtive Period tokens
    Period: u8,

    /// "1-0", "0-1", "1/2-1/2", or "*" (star means unknown result)
    Result: []u8,

    /// Represents any text not covered by the rest of the tokens
    /// It's a catch-all token and represents:
    /// * tag names (e.g. "Event" in [Event "Live Chess"])
    /// * moves (e.g. "Nge2" in "4. Nge2"),
    /// * numeric annotation glyphs (e.g. "$2" in "1. e4 $2")
    /// This token never includes whitespace
    Text: []u8,
};


const BufferedReader = struct {
    .buffer: u8[],
    
    /// Skips the next n bytes in the stream
    /// Asserts that buffer contains at least n 
    pub fn toss(self *BufferedReader, n: usize) ! {}
    
    /// Returns the next buffer.len bytes from the current position
    /// Doesn't change the seek position
    pub fn peek(self *BufferedReader, buffer []u8) !usize {}
}

/// Convert a stream of bytes into Tokens
/// Iterator
const Tokenizer = struct {
    /// Contains PGN data
    reader: BufferedReader,

    /// Used to allocate memory for tokens that don't have fixed length (e.g. comments, moves)
    allocator: std.mem.Allocator,

    ///
    pub fn init(reader: BufferedReader, allocator: std.mem.Allocator) Tokenizer {
        self.reader = reader;
        self.allocator = allocator;
    }

    /// Returns next token in a stream and moves the iterator further.
    /// Standard iterator stuff.
    fn next(_: *Tokenizer) !?Token {}

    /// Returns next token in a stream but iterator stays at the same position.
    fn peek(self: *Tokenizer) !?Token {
        const drawResult ["1/2-1/2".len]u8 = undefined;
        const decisiveResult ["1-0".len]u8 = undefined;

        reader.peek(drawResult);
        if (drawResult == "1/2-1/2") return Token.Result{"1/2-1/2"};

        reader.peek(decisiveResult);
        if (decisiveResult == "1-0") return Token.Result{"1-0"};
        if (decisiveResult == "0-1") return Token.Result{"0-1"};

        const nextChar [1]u8 = undefined;
        reader.peek(nextChar);
        reader.toss(1);
        switch (nextChar[0]) {
            '*' => {
                reader.toss(1);
                return Token.Result{"*"};
            }
            ';' => {
                // read until new line
                return Token.Comment{};
            }
            '{' => {
                // read until }
                return Token.Comment{};
            }
            '0'..'9' => {
                // read while digit
                return Token.Number{};
            }
            '.' => return Token.Period{'.'};
            '(' => return Token.OpeningParen{'('};
            ')' =>                 return Token.ClosingParen{')'};
            '[' =>                 return Token.OpeningBracket{'['};
            ']' =>                 return Token.ClosingBracket{']'};
            ' ', '\t', '\n' => return Token.Whitespace{nextChar[0]};
        }
    }
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    while (stdin.readByte()) |b| {
        try stdout.writeByte(b);
    } else |err| {
        if (err == error.EndOfStream) {
            return;
        }
        std.debug.print("Encountered an error {}", .{err});
    }
}
