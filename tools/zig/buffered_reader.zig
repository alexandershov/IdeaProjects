const std = @import("std");

/// Wrapper over any reader
fn BufferedReader(comptime ReaderType: type) type {
    const Range = struct {
        start: usize,
        end: usize,
    };

    // TODO: replace with slice
    const Ranges = struct {
        head: ?Range,
        tail: ?Range,
    };

    return struct {
        const Self = @This();

        reader: ReaderType,
        buffer: []u8,

        start: usize = 0,
        len: usize = 0,

        /// Return ranges in circular buffer at position self.start + offset
        /// Sum of ranges will be `len`
        /// This function asserts that requested `len` is available
        /// Used to fill `self.buffer` during `peek` and to fill `out`
        fn getRanges(self: *Self, offset: usize, len: usize) Ranges {
            const availableLen = self.buffer.len - ((self.start + offset) % self.buffer.len);
            std.debug.assert(len <= availableLen);
            // unboundedStart & unboundedEnd can be out of bounds of `self.buffer`
            // that's okay, we deal with it later
            var head: ?Range = null;
            var tail: ?Range = null;
            const unboundedStart = self.start + offset;
            const unboundedEnd = unboundedStart + len;
            if (self.buffer.len > unboundedStart and self.buffer.len < unboundedEnd) {
                // we need to split in two
                head = Range{ .start = unboundedStart, .end = self.buffer.len };
                tail = Range{ .start = 0, .end = unboundedEnd % self.buffer.len };
            } else {
                // self.buffer.len is on a one side (left or right) of the (unboundedStart; unboundedEnd) range
                // we just need to do everything modulo self.buffer.len,
                // modulo operation can be no-op if unboundedStart/unboundedEnd < self.buffer.len, that's fine
                tail = Range{ .start = unboundedStart % self.buffer.len, .end = unboundedEnd % self.buffer.len };
            }
            return Ranges{ .head = head, .tail = tail };
        }

        /// Fills out buffer with the next out.len bytes from the stream.
        /// Returns number of bytes read
        /// Doesn't change the stream position
        pub fn peek(self: *Self, out: []u8) !usize {
            std.debug.assert(self.buffer.len >= out.len);
            if (self.len < out.len) {
                const toRead = out.len - self.len;
                const bytesRead = try self.reader.read(out[0..toRead]);

                const ranges = self.getRanges(self.len, bytesRead);
                var outOffset: usize = 0;
                if (ranges.head) |head| {
                    @memcpy(self.buffer[head.start..head.end], out[0..(head.end - head.start)]);
                    outOffset += head.end - head.start;
                }
                if (ranges.tail) |tail| {
                    @memcpy(self.buffer[tail.start..tail.end], out[outOffset .. outOffset + tail.end - tail.start]);
                }
                self.len += bytesRead;
            }
            // TODO: handle case when `self.len` is still less than `out.len` (e.g because of EOF)
            const ranges = self.getRanges(0, @min(self.len, out.len));
            var outOffset: usize = 0;
            if (ranges.head) |head| {
                @memcpy(out[0 .. head.end - head.start], self.buffer[head.start..head.end]);
                outOffset += head.end - head.start;
            }
            if (ranges.tail) |tail| {
                @memcpy(out[outOffset .. outOffset + tail.end - tail.start], self.buffer[tail.start..tail.end]);
                outOffset += tail.end - tail.start;
            }
            return outOffset;
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
