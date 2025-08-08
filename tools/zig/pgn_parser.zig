const std = @import("std");

// pgn format spec:
// comments: ; till the end of string and {} comments
// line starting with % should be ignored


const Token = union(enum) {
    .Value: []u8,
    
    .Number: u32,
    .Symbol: []u8,
    .Comment: []u8,
    .String: []u8,
}

const Tokenizer = struct {
    reader: std.io.Reader,

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
