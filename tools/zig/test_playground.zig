const std = @import("std");
const expect = std.testing.expect;

test "always succeeds" {
    // try propagates error, it's kinda like ? in rust
    try expect(true);
}
