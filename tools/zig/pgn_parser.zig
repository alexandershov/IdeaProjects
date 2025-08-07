const std = @import("std");

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
