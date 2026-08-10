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
    std.debug.print("========ASYNC=======\n", .{});
    // zig style of doing async work is the same as working with memory allocations:
    // you explicitly pass Io instance which handles async stuff for you.
    // Default implementation is based on threads.
    try simpleAsyncExample(init.io);
    try doubleAsyncExample(init.io);
    allocAsyncExample(init.gpa, init.io) catch {};
    allocCancelAsyncExample(init.gpa, init.io) catch {};
    std.debug.print("done!\n", .{});
}

fn simpleAsyncExample(io: std.Io) !void {
    var future = io.async(doWork, .{ io, "simpleAsyncExample" });
    future.await(io);
}

fn doubleAsyncExample(io: std.Io) !void {
    var first = io.async(doWork, .{ io, "doubleAsyncExample[first]" });
    var second = io.async(doWork, .{ io, "doubleAsyncExample[second]" });
    // these two futures are executed at the same time, so we wait just 1 second
    first.await(io);
    second.await(io);
}

fn allocAsyncExample(gpa: std.mem.Allocator, io: std.Io) !void {
    var first = io.async(doAllocWork, .{ gpa, io, "allocAsyncExample[first]" });
    var second = io.async(doAllocWork, .{ gpa, io, "allocAsyncExample[second]" });

    // not optimal: even if some task fails early, we still wait for both of them
    // this will be optimized in allocCancelAsyncExample
    const firstResult = first.await(io);
    const secondResult = second.await(io);
    // we can't just do this:
    // try first.await(io);
    // try second.await(io);
    // because if first fails and second is still running, then we'll return early in try first.await(io) and will
    // resource leak from a second
    try firstResult;
    try secondResult;
}

fn allocCancelAsyncExample(gpa: std.mem.Allocator, io: std.Io) !void {
    var first = io.async(doAllocWork, .{ gpa, io, "allocCancelAsyncExample[first]" });
    // .cancel() is the same as .await() only it requests a cancellation
    // .cancel() & .await() are idempotent:
    // two .await() are idempotent
    // two .cancel() are idempotent
    // .await() & .cancel() are idempotent
    // this example is also more optimal than allocAsyncExample, because we don't wait for both futures to complete
    // with cancel we don't have memory leak, because we'll run cancel for each of the tasks, so each task will clean up  resources
    defer first.cancel(io) catch {};
    var second = io.async(doAllocWork, .{ gpa, io, "allocCancelAsyncExample[second]" });
    defer second.cancel(io) catch {};

    try first.await(io);
    try second.await(io);
}

fn doWork(io: std.Io, description: []const u8) void {
    std.debug.print("[doWork] started {s}\n", .{description});
    // sleep 1 second using Clock.awake, which is monotonic clock
    io.sleep(.fromSeconds(1), .awake) catch {};
}

fn doAllocWork(gpa: std.mem.Allocator, io: std.Io, description: []const u8) !void {
    if (std.mem.indexOf(u8, description, "first") != null) {
        return error.OutOfMemory;
    }
    const descriptionCopy = try gpa.dupe(u8, description);
    defer gpa.free(descriptionCopy);
    std.debug.print("[doAllocWork] started {s}\n", .{descriptionCopy});
    // sleep 1 second using Clock.awake, which is monotonic clock
    io.sleep(.fromSeconds(1), .awake) catch {};
}
