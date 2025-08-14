const std = @import("std");

/// Wrapper over any reader
fn BufferedReader(comptime ReaderType: type) type {
    return struct {
        const Self = @This();

        reader: ReaderType,
        buffer: []u8,

        start: usize = 0,
        len: usize = 0,

        /// Fills out buffer with the next out.len bytes from the stream.
        /// Returns number of bytes read
        /// Doesn't change the stream position
        pub fn peek(self: *Self, out: []u8) !usize {
            // TODO: simplify implementation
            std.debug.assert(self.buffer.len >= out.len);
            if (self.len < out.len) {
                // we need to read some extra bytes
                const toRead = out.len - self.len;
                const bytesRead = try self.reader.read(out[0..toRead]);
                // out[0..bytesRead] contains extra bytes that we need to append to self.buffer
                const freeHeadLen = if (self.buffer.len >= self.start + self.len) self.buffer.len - (self.start + self.len) else 0;
                var bytesRemaining = bytesRead;
                const headLenToWrite = @min(bytesRemaining, freeHeadLen);
                if (freeHeadLen > 0) {
                    const cpyStart = self.start + self.len;
                    @memcpy(self.buffer[cpyStart .. cpyStart + headLenToWrite], out[0..headLenToWrite]);
                    bytesRemaining -= headLenToWrite;
                }
                const cpyStart = (self.start + self.len + headLenToWrite) % self.buffer.len;
                @memcpy(self.buffer[cpyStart .. cpyStart + bytesRemaining], out[headLenToWrite .. headLenToWrite + bytesRemaining]);

                self.len += bytesRead;
            }
            std.debug.assert(self.len >= out.len);
            const headLen = @min(self.buffer.len - self.start, self.len);
            @memcpy(out[0..headLen], self.buffer[self.start .. self.start + headLen]);
            const tailLen = self.len - headLen;
            @memcpy(out[headLen .. headLen + tailLen], self.buffer[0..tailLen]);
            return headLen + tailLen;
        }

        /// Move stream position forward `count` bytes
        /// Stream buffer len should be >= `count`
        pub fn toss(self: *Self, count: usize) void {
            std.debug.assert(self.len >= count);
            self.len -= count;
            self.start = (self.start + count) % self.buffer.len;
        }
    };
}

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const StdInReader = BufferedReader(@TypeOf(stdin));
    var buffer: [10]u8 = undefined;
    var reader = StdInReader{ .reader = stdin, .buffer = &buffer };
    var peekaboo: [6]u8 = undefined;

    const size1 = try reader.peek(&peekaboo);
    std.debug.print("read <{s}>\n", .{peekaboo[0..size1]});
    reader.toss(size1);

    const size2 = try reader.peek(&peekaboo);
    std.debug.print("read <{s}>\n", .{peekaboo[0..size2]});

    reader.toss(1);

    const size3 = try reader.peek(&peekaboo);
    std.debug.print("read <{s}>\n", .{peekaboo[0..size3]});
}
