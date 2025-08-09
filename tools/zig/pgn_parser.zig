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
/// * .Symbol("Event")
/// * .String("Live Chess")
/// * .ClosingBracket("]")
const Token = union(enum) {
    /// Delimit PGN tags
    .OpeningBracket: u8,
    .ClosingBracket: u8,

    /// Represent tag names
    .Symbol: []u8,

    /// Delimit (possibly recursive) variations
    .OpeningParen: u8,
    .ClosingParen: u8,

    /// Represent move numbers
    .Number: u32,

    /// Comments can be of two types:
    /// ; single line comment follows semicolon
    /// { comment inside of the braces }
    .Comment: []u8,

    
    .Whitespace: []u8,

    /// Represent tag values
    .String: []u8,

}

/// Convert a stream of bytes into Tokens
const Tokenizer = struct {
    ///
    reader: std.io.Reader,

    /// 
    fn next() !?Token {}
}


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
