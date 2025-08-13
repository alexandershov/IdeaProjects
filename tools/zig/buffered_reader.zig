const std = @import("std");

fn BufferedReader(comptime ReaderType: type) type {
    return struct {
        reader: ReaderType,
        buffer: []u8,

        start: usize = 0,
        len: usize = 0,
    };
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const StdInReader = BufferedReader(@TypeOf(stdin));
    var buffer: [10]u8 = undefined;
    const reader = StdInReader{ .reader = stdin, .buffer = &buffer };
    std.debug.print("hello! {}\n", .{reader});
}
