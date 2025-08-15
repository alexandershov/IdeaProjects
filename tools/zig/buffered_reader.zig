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
            // TODO: handle case when self.len < out.len (e.g because of EOF)
            std.debug.assert(self.len >= out.len);
            const headLen = @min(self.buffer.len - self.start, self.len, out.len);
            @memcpy(out[0..headLen], self.buffer[self.start .. self.start + headLen]);
            const tailLen = @min(self.len - headLen, out.len - headLen);
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

        /// Reads data from a stream while current char is in allowedChars and not in stopChars
        /// Result will contain only characters from the allowedChars
        pub fn readWhile(self: *Self, allocator: std.mem.Allocator, allowedChars: ?[]const u8, stopChars: ?[]const u8) ![]u8 {
            var list = std.ArrayList(u8).init(allocator);
            while (true) {
                var nextChar: [1]u8 = undefined;
                const bytesRead = try self.peek(&nextChar);

                // checking for eof
                if (bytesRead == 0) break;

                if (allowedChars) |chars| {
                    if (std.mem.indexOfScalar(u8, chars, nextChar[0])) |_| {} else break;
                }
                if (stopChars) |chars| {
                    if (std.mem.indexOfScalar(u8, chars, nextChar[0])) |_| break;
                }
                try list.append(nextChar[0]);
                self.toss(1);
            }
            return list.toOwnedSlice();
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

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const gpaAllocator = gpa.allocator();
    defer {
        const gpaStatus = gpa.deinit();
        if (gpaStatus != std.heap.Check.ok) {
            std.debug.print("gpaStatus = {any}", .{gpaStatus});
        }
    }
    const stopChars: [1]u8 = .{'c'};
    const text = try reader.readWhile(gpaAllocator, null, &stopChars);
    defer gpaAllocator.free(text);
    std.debug.print("read <{s}>\n", .{text});
}
