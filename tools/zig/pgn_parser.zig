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
    /// Delimits PGN tags
    .OpeningBracket: u8,
    .ClosingBracket: u8,

    /// Represents tag names
    .Symbol: []u8,

    /// Delimits (possibly recursive) variations
    .OpeningParen: u8,
    .ClosingParen: u8,

    /// Represents move numbers
    .Number: u32,

    /// Comments can be of two types:
    /// ; single line comment follows semicolon
    /// { comment inside of the braces }
    .Comment: []u8,

    /// Includes spaces, tabs, newlines
    .Whitespace: []u8,

    /// Represents tag values
    .String: []u8,

    /// Represents period after a white move number `1. e4`
    .Period u8,

    /// Represents period after a black move number `1... e5`
    .TriplePeriod []u8,

    /// Represents the move, e.g. "Nf3" or "O-O-O".
    /// Note that castle is represented with capital letter O, not zero (0)
    /// That's part of PGN spec
    .Move []u8,

    /// Represents Numeric Annotation Glyph, e.g. "$2" in "1. e4 $2"
    .MoveAnnotation []u8

    /// "1-0", "0-1", "1/2-1/2", or "*" (unknown result)
    /// Follows the 
    .Result []u8,
}

/// Convert a stream of bytes into Tokens
/// Iterator
const Tokenizer = struct {
    /// Contains PGN data
    reader: std.io.Reader,

    /// Returns next token in a stream and moves the iterator further.
    /// Standard iterator stuff.
    fn next(self *Tokenizer) !?Token {}

    /// Returns next token in a stream but iterator stays at the same position.
    fn peek(self *Tokenizer) !?Token {}
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
