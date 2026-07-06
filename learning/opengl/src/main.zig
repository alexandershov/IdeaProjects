const std = @import("std");
const Io = std.Io;
const g = @import("hellogl.zig");

pub export fn hello_gl() void {
    _ = g.SDL_Init(g.SDL_INIT_VIDEO);
    _ = g.SDL_GL_SetAttribute(g.SDL_GL_CONTEXT_MAJOR_VERSION, 4);
    _ = g.SDL_GL_SetAttribute(g.SDL_GL_CONTEXT_MINOR_VERSION, 1);
    _ = g.SDL_GL_SetAttribute(g.SDL_GL_CONTEXT_PROFILE_MASK, g.SDL_GL_CONTEXT_PROFILE_CORE);
    var window: ?*g.SDL_Window = g.SDL_CreateWindow("Testing OpenGL", @bitCast(@as(c_uint, @truncate(g.SDL_WINDOWPOS_CENTERED_MASK | @as(c_uint, @bitCast(@as(c_int, @as(c_int, 0))))))), @bitCast(@as(c_uint, @truncate(g.SDL_WINDOWPOS_CENTERED_MASK | @as(c_uint, @bitCast(@as(c_int, @as(c_int, 0))))))), 800, 600, g.SDL_WINDOW_OPENGL);
    _ = &window;
    var context: g.SDL_GLContext = g.SDL_GL_CreateContext(window);
    _ = &context;
    var vertexShaderSource: [*c]const u8 = "#version 410 core\nlayout (location = 0) in vec3 aPos;\nlayout (location = 1) in vec3 aColor;\nout vec4 vertexColor;\nuniform vec4 colorDelta;\nvoid main()\n{\nvec3 tmpPos = aPos.zyx;\n  gl_Position = vec4(tmpPos.zyx, 1.0);\n  vertexColor = vec4(aColor, 1.0f) + colorDelta;\n}\n";
    _ = &vertexShaderSource;
    var vertexShader: c_uint = g.glCreateShader(g.GL_VERTEX_SHADER);
    _ = &vertexShader;
    g.glShaderSource(vertexShader, 1, &vertexShaderSource, null);
    g.glCompileShader(vertexShader);
    var vertexShaderCompiled: c_int = undefined;
    _ = &vertexShaderCompiled;
    g.glGetShaderiv(vertexShader, g.GL_COMPILE_STATUS, &vertexShaderCompiled);
    if (!(vertexShaderCompiled != 0)) {
        _ = g.printf("vertex shader failed to compile!\n");
        g.exit(1);
    }
    var fragmentShaderSource: [*c]const u8 = "#version 410 core\nin vec4 vertexColor;\nout vec4 Color;\nvoid main()\n{\n Color = vertexColor;\n}\n";
    _ = &fragmentShaderSource;
    var fragmentShader: c_uint = g.glCreateShader(g.GL_FRAGMENT_SHADER);
    _ = &fragmentShader;
    g.glShaderSource(fragmentShader, 1, &fragmentShaderSource, null);
    g.glCompileShader(fragmentShader);
    var fragmentShaderCompiled: c_int = undefined;
    _ = &fragmentShaderCompiled;
    g.glGetShaderiv(fragmentShader, g.GL_COMPILE_STATUS, &fragmentShaderCompiled);
    if (!(fragmentShaderCompiled != 0)) {
        _ = g.printf("fragment shader failed to compile!\n");
        g.exit(1);
    }
    var shaderProgram: c_uint = g.glCreateProgram();
    _ = &shaderProgram;
    g.glAttachShader(shaderProgram, vertexShader);
    g.glAttachShader(shaderProgram, fragmentShader);
    g.glLinkProgram(shaderProgram);
    var programLinked: c_int = undefined;
    _ = &programLinked;
    g.glGetProgramiv(shaderProgram, g.GL_LINK_STATUS, &programLinked);
    if (!(programLinked != 0)) {
        _ = g.printf("shader program failed to link!\n");
        g.exit(1);
    }
    g.glDeleteShader(vertexShader);
    g.glDeleteShader(fragmentShader);
    var VBO: c_uint = undefined;
    _ = &VBO;
    g.glGenBuffers(1, &VBO);
    var VAO: c_uint = undefined;
    _ = &VAO;
    g.glGenVertexArrays(1, &VAO);
    g.glBindVertexArray(VAO);
    g.glBindBuffer(g.GL_ARRAY_BUFFER, VBO);
    var vertices: [18]f32 = [18]f32{
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
        0.0,
        0.5,
        0.0,
        0.0,
        0.0,
        1.0,
        0.0,
        0.5,
        0.5,
        0.0,
        0.0,
        0.0,
        1.0,
    };
    _ = &vertices;
    g.glBufferData(g.GL_ARRAY_BUFFER, @bitCast(@as(c_ulong, @truncate(@sizeOf(@TypeOf(vertices))))), @ptrCast(@alignCast(@as([*c]f32, @ptrCast(@alignCast(&vertices))))), g.GL_STATIC_DRAW);
    g.glVertexAttribPointer(0, 3, g.GL_FLOAT, g.GL_FALSE, @bitCast(@as(c_uint, @truncate(@as(c_ulong, 6) *% @sizeOf(f32)))), null);
    g.glEnableVertexAttribArray(0);
    g.glVertexAttribPointer(1, 3, g.GL_FLOAT, g.GL_FALSE, @bitCast(@as(c_uint, @truncate(@as(c_ulong, 6) *% @sizeOf(f32)))), @ptrFromInt(@as(c_ulong, 3) *% @sizeOf(f32)));
    g.glEnableVertexAttribArray(1);
    g.glBindBuffer(g.GL_ARRAY_BUFFER, 0);
    g.glBindVertexArray(0);
    var running: bool = g.true != 0;
    _ = &running;
    var event: g.SDL_Event = undefined;
    _ = &event;
    var redDelta: f32 = 0.0;
    _ = &redDelta;
    while (running) {
        while (g.SDL_PollEvent(&event) != 0) {
            if (event.type == @as(g.Uint32, g.SDL_QUIT)) {
                running = g.false != 0;
            }
        }
        g.glClearColor(0.2, 0.3, 0.3, 1.0);
        g.glClear(g.GL_COLOR_BUFFER_BIT);
        g.glUseProgram(shaderProgram);
        var colorDeltaLocation: c_int = g.glGetUniformLocation(shaderProgram, "colorDelta");
        _ = &colorDeltaLocation;
        redDelta -= 0.0001;
        if (redDelta < -@as(f32, 0.999)) {
            redDelta = 0.0;
        }
        g.glUniform4f(colorDeltaLocation, redDelta, 0.0, 0.0, 0.0);
        g.glBindVertexArray(VAO);
        g.glDrawArrays(g.GL_TRIANGLES, 0, 3);
        g.SDL_GL_SwapWindow(window);
    }
    g.SDL_GL_DeleteContext(context);
    g.SDL_DestroyWindow(window);
    g.SDL_Quit();
}

pub fn main(init: std.process.Init) !void {
    // Prints to stderr, unbuffered, ignoring potential errors.
    hello_gl();
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // This is appropriate for anything that lives as long as the process.
    const arena: std.mem.Allocator = init.arena.allocator();

    // Accessing command line arguments:
    const args = try init.minimal.args.toSlice(arena);
    for (args) |arg| {
        std.log.info("arg: {s}", .{arg});
    }

    // In order to do I/O operations need an `Io` instance.
    const io = init.io;

    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    try stdout_writer.flush(); // Don't forget to flush!
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    try std.testing.fuzz({}, testOne, .{});
}

fn testOne(context: void, smith: *std.testing.Smith) !void {
    _ = context;
    // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!

    const gpa = std.testing.allocator;
    var list: std.ArrayList(u8) = .empty;
    defer list.deinit(gpa);
    while (!smith.eos()) switch (smith.value(enum { add_data, dup_data })) {
        .add_data => {
            const slice = try list.addManyAsSlice(gpa, smith.value(u4));
            smith.bytes(slice);
        },
        .dup_data => {
            if (list.items.len == 0) continue;
            if (list.items.len > std.math.maxInt(u32)) return error.SkipZigTest;
            const len = smith.valueRangeAtMost(u32, 1, @min(32, list.items.len));
            const off = smith.valueRangeAtMost(u32, 0, @intCast(list.items.len - len));
            try list.appendSlice(gpa, list.items[off..][0..len]);
            try std.testing.expectEqualSlices(
                u8,
                list.items[off..][0..len],
                list.items[list.items.len - len ..],
            );
        },
    };
}
