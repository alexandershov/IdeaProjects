const std = @import("std");

// errors are values in zig
// kinda like enums
const DivideError = error{
    DivisionByZero,
};

// ! creates an error union type
fn divide(x: u32, y: u32) DivideError!u32 {
    if (y == 0) {
        return DivideError.DivisionByZero;
    }
    return x / y;
}

pub fn main() void {
    // immutable value
    const count: u32 = 30;
    // next line doesn't work because count is const
    // count += 1;

    // mutable value
    var mutableCount: u32 = 22;
    mutableCount += 1;

    // like in go, executed in a reverse order, so it'll print "second defer" and then "first defer"
    defer std.debug.print("first defer\n", .{});
    defer std.debug.print("second defer\n", .{});
    // array
    const arr = [_]u32{ 1, 2, 3, 4, 5 };
    std.debug.print("Hello world, I've counted {} things and {} mutable things, also array {any} \n", .{ count, mutableCount, arr });

    std.debug.print("arr.len = {}\n", .{arr.len});

    // slices are pointers that also contain count of elements that they point to
    const slice = arr[3..];
    std.debug.print("slice.length = {}\n", .{slice.len});

    for (arr, 0..) |item, index| {
        std.debug.print("arr[{}] = {}\n", .{ index, item });
    }

    std.debug.print("divide(3, 2) = {any}\n", .{divide(3, 2)});

    std.debug.print("divide(3, 0) = {any}\n", .{divide(3, 0)});

    // catch allows fallback to default value in case of error
    const divisionByZero = divide(3, 0) catch 666;

    // kinda like pattern matching on error union, else with err capture is required
    if (divide(3, 2)) |v| {
        std.debug.print("divide(3, 2) = {}\n", .{v});
    } else |err| {
        std.debug.print("divide(3, 2) = {}\n", .{err});
    }

    std.debug.print("divisionByZero = {any}\n", .{divisionByZero});

    // optional
    const optCount: ?u32 = 32;
    // orelse unwraps optional
    std.debug.print("optCount = {any}\n", .{optCount orelse 18});
    // unconditinal unwrap
    std.debug.print("optCount + 1 = {}\n", .{(optCount orelse unreachable) + 1});
    // shorthand for unconditinal unwrap
    std.debug.print("optCount + 1 = {}\n", .{(optCount.?) + 1});
    // payload capture, v is an u32
    if (optCount) |v| {
        std.debug.print("v = {}\n", .{v});
    }
}
