// run me with ``zig run async.zig`

const std = @import("std");

pub fn main(init: std.process.Init) !void {
    // this is juicy main: std.process.Init is a special kind of argument
    // that gives us allocator, Io, and other stuff
    // full description is here: https://ziglang.org/download/0.16.0/release-notes.html#Juicy-Main
    // here are the most useful juicy main parts:
    // init.environ_map contains current process environment
    // init.gpa contains general purpose allocator
    std.debug.print("========ENVVARS=======\n", .{});
    for (init.environ_map.keys(), init.environ_map.values()) |name, value| {
        std.debug.print("{s} = {s}\n", .{ name, value });
    }

    // toSlice requires an arena allocator, thankfully init provides it
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    std.debug.print("========ARGUMENTS=======\n", .{});
    for (0.., args) |i, arg| {
        // args[0] is the program name
        std.debug.print("args[{}] = {s}\n", .{ i, arg });
    }

    std.debug.print("done!\n", .{});
}
