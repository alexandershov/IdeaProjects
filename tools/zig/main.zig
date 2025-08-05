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

    for (arr, 0..) |item, index| {
        std.debug.print("arr[{}] = {}\n", .{ index, item });
    }

    std.debug.print("divide(3, 2) = {any}\n", .{divide(3, 2)});
    std.debug.print("divide(3, 0) = {any}\n", .{divide(3, 0)});
}
