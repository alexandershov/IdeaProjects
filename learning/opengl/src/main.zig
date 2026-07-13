const std = @import("std");
const Io = std.Io;
const g = @import("hellogl.zig");
const stbImage = @cImport({
    @cDefine("STB_IMAGE_IMPLEMENTATION", {});
    @cInclude("stb_image.h");
});

pub fn hello_gl() u8 {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const gpa = debug_allocator.allocator();

    var threaded: std.Io.Threaded = .init(gpa, std.Io.Threaded.InitOptions{});
    defer threaded.deinit();
    const io = threaded.io();

    _ = g.SDL_Init(g.SDL_INIT_VIDEO);

    // use opengl 4.1
    _ = g.SDL_GL_SetAttribute(g.SDL_GL_CONTEXT_MAJOR_VERSION, 4);
    _ = g.SDL_GL_SetAttribute(g.SDL_GL_CONTEXT_MINOR_VERSION, 1);

    // core profile (i.e. "New way of doing OpenGL"): usage of glBegin/glEnd is forbidden
    _ = g.SDL_GL_SetAttribute(g.SDL_GL_CONTEXT_PROFILE_MASK, g.SDL_GL_CONTEXT_PROFILE_CORE);

    const window: ?*g.SDL_Window = g.SDL_CreateWindow("Testing OpenGL with zig", // window title
        g.SDL_WINDOWPOS_CENTERED, // x position of the window
        g.SDL_WINDOWPOS_CENTERED, // y position of the window
        800, // width
        600, // height
        g.SDL_WINDOW_OPENGL // window is usable with OpenGL
    );
    const context: g.SDL_GLContext = g.SDL_GL_CreateContext(window);
    var vertexShaderSource: [*c]const u8 = @embedFile("./vertex_shader.glsl");
    // vertex shader operates, ahem, on vertices
    const vertexShader: c_uint = g.glCreateShader(g.GL_VERTEX_SHADER);
    // set source code to a shader, it takes an array of string, we pass just 1 string
    // NULL means that strings are null-terminated
    g.glShaderSource(vertexShader, 1, &vertexShaderSource, null);

    var start: std.Io.Timestamp = std.Io.Timestamp.now(io, std.Io.Clock.awake);
    var end: std.Io.Timestamp = undefined;

    g.glCompileShader(vertexShader);
    end = std.Io.Timestamp.now(io, std.Io.Clock.awake);
    var duration: i64 = std.Io.Duration.toMicroseconds(start.durationTo(end));
    // vertex shader compilation is ~600us
    std.debug.print("vertex shader compilation took {}us\n", .{duration});

    var vertexShaderCompiled: c_int = undefined;
    g.glGetShaderiv(vertexShader, g.GL_COMPILE_STATUS, &vertexShaderCompiled);
    if (!(vertexShaderCompiled != 0)) {
        printShaderCompileError(vertexShader);
        return 1;
    }
    var fragmentShaderSource: [*c]const u8 = @embedFile("./fragment_shader.glsl");
    // fragment shader operates, ahem, on fragments (of a screen) e.g. group of pixels
    const fragmentShader: c_uint = g.glCreateShader(g.GL_FRAGMENT_SHADER);
    // compilation process is the same as for vertexShader
    g.glShaderSource(fragmentShader, 1, &fragmentShaderSource, null);

    start = std.Io.Timestamp.now(io, std.Io.Clock.awake);
    g.glCompileShader(fragmentShader);
    end = std.Io.Timestamp.now(io, std.Io.Clock.awake);
    duration = std.Io.Duration.toMicroseconds(start.durationTo(end));
    // fragment shader compilation is ~150us
    std.debug.print("fragment shader compilation took {}us\n", .{duration});

    var fragmentShaderCompiled: c_int = undefined;
    g.glGetShaderiv(fragmentShader, g.GL_COMPILE_STATUS, &fragmentShaderCompiled);
    if (!(fragmentShaderCompiled != 0)) {
        printShaderCompileError(fragmentShader);
        return 1;
    }
    // shader program contains several shaders
    const shaderProgram: c_uint = g.glCreateProgram();
    g.glAttachShader(shaderProgram, vertexShader);
    g.glAttachShader(shaderProgram, fragmentShader);
    g.glLinkProgram(shaderProgram);
    var programLinked: c_int = undefined;
    g.glGetProgramiv(shaderProgram, g.GL_LINK_STATUS, &programLinked);
    if (!(programLinked != 0)) {
        std.debug.print("shader program failed to link!\n", .{});
        std.process.exit(1);
    }

    // we don't need shader objects after we've linked them into a program
    g.glDeleteShader(vertexShader);
    g.glDeleteShader(fragmentShader);

    // Vertex Buffer Object, used to send vertices to GPU memory
    var VBO: c_uint = undefined;
    // init 1 buffer object
    g.glGenBuffers(1, &VBO);
    // Vertex Array Object - holds VBO and its attribute configuration
    // Essentially it's a way to store VBO and its configuration done by *AttribPointer* functions
    // in one place and then use this place to draw
    // OpenGL core platform actually requires VAO to draw
    var VAO: c_uint = undefined;

    // init 1 VAO object
    g.glGenVertexArrays(1, &VAO);
    // after call to glBindVertexArray VAO will remember *AttribPointer* functions
    g.glBindVertexArray(VAO);
    // from now on all operations on GL_ARRAY_BUFFER will operate on VBO
    // this is kinda like binding of variable (think `let` in Common Lisp)
    g.glBindBuffer(g.GL_ARRAY_BUFFER, VBO);
    // Coordinates are in Normalized Device Coordinates - range is [-1.0; 1.0]
    // our window is 800x600, this means that x == 0 will be translated to 400
    // and y == 0 will be translated to 300 - it's lerp
    var vertices: [18]f32 = [18]f32{
        //x    y    z    r    g    b
        0.0, 0.0, 0.0, 1.0, 0.0, 0.0,
        0.5, 0.0, 0.0, 0.0, 1.0, 0.0,
        0.5, 0.5, 0.0, 0.0, 0.0, 1.0,
    };
    // copy data in the currently bound buffer
    // GL_STATIC_DRAW means - data will be set only once and used many times
    g.glBufferData(g.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), @ptrCast(@alignCast(@as([*c]f32, @ptrCast(@alignCast(&vertices))))), g.GL_STATIC_DRAW);

    // tell OpenGL how to extract positions from our vector data (array of 18 floats)

    g.glVertexAttribPointer(0, // attribute position, same as location value in vertex shader
        3, // attribute size, it's a vec3 in vertex shader
        g.GL_FLOAT, // attribute type
        g.GL_FALSE, // normalize data
        @bitCast(@as(c_uint, @truncate(@as(c_ulong, 6) *% @sizeOf(f32)))), // stride: distance between consecutive attributes
        null // offset of data in the buffer
    );
    // enable attribute at location 0
    g.glEnableVertexAttribArray(0);
    // tell OpenGL how to extract colors from our vector data (array of 18 floats)
    g.glVertexAttribPointer(1, // attribute position, same as location value in vertex shader
        3, // attribute size, it's a vec3 in vertex shader
        g.GL_FLOAT, // attribute type
        g.GL_FALSE, // normalize data
        @bitCast(@as(c_uint, @truncate(@as(c_ulong, 6) *% @sizeOf(f32)))), // normalize data
        @ptrFromInt(@as(c_ulong, 3) *% @sizeOf(f32)) // offset of data in the buffer
    );
    // enable attribute at location 1
    g.glEnableVertexAttribArray(1);

    // we'll have 3 vertices with 3 colors, but fragment shader output will be quite colorful
    // because it'll interpolate colors

    // unbind VBO
    g.glBindBuffer(g.GL_ARRAY_BUFFER, 0);
    // unbind current VAO
    g.glBindVertexArray(0);
    var running: bool = g.true != 0;
    var event: g.SDL_Event = undefined;
    var redDelta: f32 = 0.0;
    while (running) {
        while (g.SDL_PollEvent(&event) != 0) {
            if (event.type == @as(g.Uint32, g.SDL_QUIT)) {
                running = g.false != 0;
            }
        }
        // clear color buffers, this is OpenGL function
        // As I understand this is to reset OpenGL state machine on each frame
        // https://registry.khronos.org/OpenGL-Refpages/gl4/html/glClear.xhtml
        g.glClearColor(0.2, 0.3, 0.3, 1.0);
        g.glClear(g.GL_COLOR_BUFFER_BIT);
        g.glUseProgram(shaderProgram);
        // assigning uniform (aka global) value
        const colorDeltaLocation: c_int = g.glGetUniformLocation(shaderProgram, "colorDelta");
        // 4f is like hungarian notation, here it means assign vec4 to a location
        redDelta -= 0.0001;
        if (redDelta < -@as(f32, 0.999)) {
            redDelta = 0.0;
        }
        g.glUniform4f(colorDeltaLocation, redDelta, 0.0, 0.0, 0.0);
        // use VAO
        g.glBindVertexArray(VAO);
        // draw triangles
        g.glDrawArrays(g.GL_TRIANGLES, 0, // starting index of vertex array
            3 // how many vertices to draw, there are 3 vertices in a triangle
        );
        // update a window with OpenGL rendering
        // default OpenGL context uses double buffering, hence "swap" of the background/in-progress buffer
        // to the "active/screen" buffer
        g.SDL_GL_SwapWindow(window);
    }
    // clean up & exit
    g.SDL_GL_DeleteContext(context);
    g.SDL_DestroyWindow(window);
    g.SDL_Quit();
    return 0;
}

fn printShaderCompileError(shader: c_uint) void {
    var shaderCompileError: [512]u8 = undefined;
    var shaderCompileErrorLen: i32 = undefined;
    g.glGetShaderInfoLog(shader, shaderCompileError.len, &shaderCompileErrorLen, &shaderCompileError);

    // determine shader type
    var shaderTypeCode: i32 = undefined;
    g.glGetShaderiv(shader, g.GL_SHADER_TYPE, &shaderTypeCode);
    var shaderType: []const u8 = "<unknown shader type>";
    if (shaderTypeCode == g.GL_VERTEX_SHADER) {
        shaderType = "vertex";
    } else if (shaderTypeCode == g.GL_FRAGMENT_SHADER) {
        shaderType = "fragment";
    }
    std.debug.print("{s} shader failed to compile! {s}\n", .{ shaderType, shaderCompileError[0..@intCast(shaderCompileErrorLen)] });
}

pub fn main() !u8 {
    return hello_gl();
}
