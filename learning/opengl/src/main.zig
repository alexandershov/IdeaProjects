const std = @import("std");
const Io = std.Io;
const g = @import("hellogl.zig");
const stb = @cImport({
    @cInclude("stb_image.h");
});

const VertexAttribs = struct {
    stride: usize,
    offsets: []const usize,
};

const Point = struct {
    x: f32,
    y: f32,
};

pub fn hello_gl() !u8 {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const gpa = debug_allocator.allocator();

    var threaded: std.Io.Threaded = .init(gpa, std.Io.Threaded.InitOptions{});
    defer threaded.deinit();
    const io = threaded.io();

    var texWidth: c_int = undefined;
    var texHeight: c_int = undefined;
    var numChannels: c_int = undefined;
    const texData: [*c]u8 = stb.stbi_load("src/wall.jpg", &texWidth, &texHeight, &numChannels, 0);
    if (texData == null) {
        std.debug.print("could not load src/wall.jpg\n", .{});
        return 1;
    }
    defer stb.stbi_image_free(texData);
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
        800, // height
        g.SDL_WINDOW_OPENGL // window is usable with OpenGL
    );
    const context: g.SDL_GLContext = g.SDL_GL_CreateContext(window);

    const shaderProgram: c_uint = buildShaderProgram(io, "./vertex_shader.glsl", "./fragment_shader.glsl");
    const quadShaderProgram: c_uint = buildShaderProgram(io, "./quad_vertex_shader.glsl", "./quad_fragment_shader.glsl");
    const passThroughShaderProgram: c_uint = buildShaderProgram(io, "./pass_through_vertex_shader.glsl", "./pass_through_fragment_shader.glsl");
    // there's a default framebuffer and by default we render to it
    // but we can create another framebuffer, render to it, make a texture out of it
    // and then create quad that fills the entire screen and then
    // apply post-processing effects when rendering quad with the texture from our framebuffer
    // we can e.g. apply grayscale effects, motion blur, etc
    var fbo: u32 = undefined;
    g.glGenFramebuffers(1, &fbo);
    defer g.glDeleteFramebuffers(1, &fbo);
    g.glBindFramebuffer(g.GL_FRAMEBUFFER, fbo);

    // create a texture that framebuffer will render to
    var texColorBuffer: u32 = undefined;
    g.glGenTextures(1, &texColorBuffer);
    g.glBindTexture(g.GL_TEXTURE_2D, texColorBuffer);
    g.glTexImage2D(g.GL_TEXTURE_2D, 0, g.GL_RGB, 800, 800, 0, g.GL_RGB, g.GL_UNSIGNED_BYTE, null);
    g.glTexParameteri(g.GL_TEXTURE_2D, g.GL_TEXTURE_MIN_FILTER, g.GL_LINEAR);
    g.glTexParameteri(g.GL_TEXTURE_2D, g.GL_TEXTURE_MAG_FILTER, g.GL_LINEAR);
    // unbind texture
    g.glBindTexture(g.GL_TEXTURE_2D, 0);
    // attach texture to the bound framebuffer
    g.glFramebufferTexture2D(g.GL_FRAMEBUFFER, g.GL_COLOR_ATTACHMENT0, g.GL_TEXTURE_2D, texColorBuffer, 0);

    var rbo: u32 = undefined;
    // renderbuffers are useful if we don't need to read from them explicitly
    // we can use renderbuffers for depth buffer & stencil buffer
    // depth buffer (also called z-buffer) is used by opengl to determine which fragment needs to be rendered
    // e.g. if we have two fragments at the same location, then depth buffer will be used to determine which fragment to render
    // (we should render the closest fragment)
    // naive implementation will execute fragment shader many times at different depth
    // better implementation will not execute fragment shader if it'll lose by depth check anyway
    // stencil buffer allows us to output fragments only if they match (or not match) value in the stencil buffer
    // it can be used for drawing borders:
    // * render and write to stencil buffer
    // * disable writing to stencil buffer
    // * scale objects and render only it doesn't match stencil value
    // * this will give us an effect of drawing a border (because we'll render only stuff that was not rendered before)
    g.glGenRenderbuffers(1, &rbo);
    g.glBindRenderbuffer(g.GL_RENDERBUFFER, rbo);
    g.glRenderbufferStorage(
        g.GL_RENDERBUFFER,
        g.GL_DEPTH24_STENCIL8, // use 24 bits for depth and 8 bits for stencil
        800,
        800,
    );
    g.glBindRenderbuffer(g.GL_RENDERBUFFER, 0);
    // attach renderbuffer to attachments to depth & stencil attachments of framebuffer
    g.glFramebufferRenderbuffer(g.GL_FRAMEBUFFER, g.GL_DEPTH_STENCIL_ATTACHMENT, g.GL_RENDERBUFFER, rbo);

    if (g.glCheckFramebufferStatus(g.GL_FRAMEBUFFER) != g.GL_FRAMEBUFFER_COMPLETE) {
        std.debug.print("framebuffer is not complete", .{});
        return 1;
    }

    // bind default framebuffer
    g.glBindFramebuffer(g.GL_FRAMEBUFFER, 0);

    var texture: u32 = undefined;
    g.glGenTextures(1, &texture);
    // bind texture to GL_TEXTURE_2D variable - usual binding stuff
    g.glBindTexture(g.GL_TEXTURE_2D, texture);
    // we control what happens when texture coordinates are outside of the [-1.0; 1.0]
    // here we set it up to repeat texture for s (x) & t (y) axes
    g.glTexParameteri(g.GL_TEXTURE_2D, g.GL_TEXTURE_WRAP_S, g.GL_REPEAT);
    g.glTexParameteri(g.GL_TEXTURE_2D, g.GL_TEXTURE_WRAP_T, g.GL_REPEAT);
    // let's say we found a texel (pixel inside of the texture: "TEXture ELement") that represents our coordinates
    // we can control the color of this texel
    // GL_LINEAR will interpolate texel color based on the colors of its neighbours
    // there's also GL_NEAREST, that just takes the color of nearest texel
    // these are called texture filters and we can have different filters if our texture
    // was upscaled or downscaled
    g.glTexParameteri(g.GL_TEXTURE_2D, g.GL_TEXTURE_MIN_FILTER, g.GL_LINEAR);
    g.glTexParameteri(g.GL_TEXTURE_2D, g.GL_TEXTURE_MAG_FILTER, g.GL_LINEAR);
    g.glTexImage2D(
        g.GL_TEXTURE_2D, // operate on currently bound GL_TEXTURE_2D
        0, // no mipmap, mipmaps are kinda like LOD for textures - we can have smaller textures based on a surface of the polygon
        g.GL_RGB,
        texWidth,
        texHeight,
        0, // always 0, legacy
        g.GL_RGB,
        g.GL_UNSIGNED_BYTE,
        texData,
    );

    var triangleVertices: [24]f32 = [24]f32{
        //x    y    z    r    g    b  texture coordinates (st)
        0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0,
        0.5, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0,
        0.5, 0.5, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0,
    };
    const triangleVAO: c_uint = buildVAO(&triangleVertices, .{
        // we tell OpenGL how to extract positions from our vector data (array of 24 floats)
        // stride: distance between consecutive attributes is 8 for triangleVertices
        // internally buildVAO will multiply it by @sizeOf(f32)
        .stride = 8,
        // offsets of data in a buffer
        // xyz has offset 0
        // rgb has offset 3
        // st has offset 6
        .offsets = &.{ 0, 3, 6 },
    });

    var quadVertices: [24]f32 = [24]f32{
        // x    y    s    t
        -1.0, 1.0,  0.0, 1.0,
        -1.0, -1.0, 0.0, 0.0,
        1.0,  -1.0, 1.0, 0.0,
        -1.0, 1.0,  0.0, 1.0,
        1.0,  1.0,  1.0, 1.0,
        1.0,  -1.0, 1.0, 0.0,
    };
    const quadVAO: c_uint = buildVAO(&quadVertices, .{
        .stride = 4,
        // offsets of data in a buffer
        // xy has offset 0
        // st has offset 2
        .offsets = &.{ 0, 2 },
    });

    const circleCenter: Point = .{ .x = 0.0, .y = 0.0 };
    const circleRadius: f32 = 0.2;
    var angle: f32 = 0.0;
    const numSectors = 60;
    const angleStep: f32 = 2.0 * std.math.pi / @as(f32, @floatFromInt(numSectors));
    var circleVertices: std.ArrayList(f32) = .empty;
    defer circleVertices.deinit(gpa);
    var prevPoint: Point = pointAtAngle(angle, circleCenter, circleRadius);
    var numCircleTriangles: i32 = 0;
    const blue: []const f32 = &.{ 0.0, 0.0, 1.0 };
    for (0..numSectors) |_| {
        const curPoint = pointAtAngle(@min(2 * std.math.pi, angle + angleStep), circleCenter, circleRadius);

        // add blue triangle
        try circleVertices.appendSlice(gpa, &.{ circleCenter.x, circleCenter.y, 0.0 });
        try circleVertices.appendSlice(gpa, blue);

        try circleVertices.appendSlice(gpa, &.{ prevPoint.x, prevPoint.y, 0.0 });
        try circleVertices.appendSlice(gpa, blue);

        try circleVertices.appendSlice(gpa, &.{ curPoint.x, curPoint.y, 0.0 });
        try circleVertices.appendSlice(gpa, blue);

        numCircleTriangles += 1;
        prevPoint = curPoint;
        angle += angleStep;
    }
    const circleVAO: c_uint = buildVAO(circleVertices.items, .{
        // stride = xyz + rgb = 6
        .stride = 6,
        // offsets = xyz, rgb
        .offsets = &.{ 0, 3 },
    });

    var running: bool = g.true != 0;
    var event: g.SDL_Event = undefined;
    var redDelta: f32 = 0.0;
    var numUnaccountedFrames: usize = 0;
    var unaccountedFramesStartedAt: std.Io.Timestamp = std.Io.Clock.awake.now(io);
    while (running) {
        while (g.SDL_PollEvent(&event) != 0) {
            if (event.type == @as(g.Uint32, g.SDL_QUIT)) {
                running = g.false != 0;
            }
        }
        // after this bind all read/write framebuffer operations will affect this framebuffer
        g.glBindFramebuffer(g.GL_FRAMEBUFFER, fbo);
        // clear color buffers, this is OpenGL function
        // As I understand this is to reset OpenGL state machine on each frame
        // https://registry.khronos.org/OpenGL-Refpages/gl4/html/glClear.xhtml
        g.glClearColor(0.2, 0.3, 0.3, 1.0);
        g.glClear(g.GL_COLOR_BUFFER_BIT | g.GL_DEPTH_BUFFER_BIT);
        g.glEnable(g.GL_DEPTH_TEST);
        g.glUseProgram(shaderProgram);
        // assigning uniform (aka global) value
        const colorDeltaLocation: c_int = g.glGetUniformLocation(shaderProgram, "colorDelta");
        // 4f is like hungarian notation, here it means assign vec4 to a location
        redDelta -= 0.0001;
        if (redDelta < -@as(f32, 0.999)) {
            redDelta = 0.0;
        }
        g.glUniform4f(colorDeltaLocation, redDelta, 0.0, 0.0, 0.0);
        g.glBindTexture(g.GL_TEXTURE_2D, texture);
        // use VAO
        g.glBindVertexArray(triangleVAO);
        // draw triangles
        g.glDrawArrays(g.GL_TRIANGLES, 0, // starting index of vertex array
            3 // how many vertices to draw, there are 3 vertices in a triangle
        );

        // draw a circle
        g.glUseProgram(passThroughShaderProgram);
        g.glBindVertexArray(circleVAO);
        g.glDrawArrays(g.GL_TRIANGLES, 0, numCircleTriangles * 3);

        g.glBindFramebuffer(g.GL_FRAMEBUFFER, 0);
        g.glClearColor(1.0, 1.0, 1.0, 1.0);
        g.glClear(g.GL_COLOR_BUFFER_BIT);
        g.glUseProgram(quadShaderProgram);
        // use VAO
        g.glBindVertexArray(quadVAO);
        g.glDisable(g.GL_DEPTH_TEST);
        g.glBindTexture(g.GL_TEXTURE_2D, texColorBuffer);
        // draw triangles
        g.glDrawArrays(g.GL_TRIANGLES, 0, // starting index of vertex array
            6 // how many vertices to draw, there are 6 vertices in quad
        );

        // update a window with OpenGL rendering
        // default OpenGL context uses double buffering, hence "swap" of the background/in-progress buffer
        // to the "active/screen" buffer
        g.SDL_GL_SwapWindow(window);
        numUnaccountedFrames += 1;
        if (numUnaccountedFrames == 100) {
            const unaccountedFramesEndedAt = std.Io.Clock.awake.now(io);
            const duration: usize = @intCast(std.Io.Duration.toMicroseconds(unaccountedFramesStartedAt.durationTo(unaccountedFramesEndedAt)));
            const fps: usize = 1_000_000 * numUnaccountedFrames / duration;
            std.debug.print("fps = {}\n", .{ fps });
            numUnaccountedFrames = 0;
            unaccountedFramesStartedAt = unaccountedFramesEndedAt;
        }
    }
    // clean up & exit
    g.SDL_GL_DeleteContext(context);
    g.SDL_DestroyWindow(window);
    g.SDL_Quit();
    return 0;
}

pub fn buildShaderProgram(io: std.Io, comptime vertexShaderPath: []const u8, comptime fragmentShaderPath: []const u8) c_uint {
    var vertexShaderSource: [*c]const u8 = @embedFile(vertexShaderPath);
    // vertex shader operates, ahem, on vertices
    const vertexShader: c_uint = g.glCreateShader(g.GL_VERTEX_SHADER);
    // set source code to a shader, it takes an array of string, we pass just 1 string
    // NULL means that strings are null-terminated
    g.glShaderSource(vertexShader, 1, &vertexShaderSource, null);

    var start: std.Io.Timestamp = std.Io.Clock.awake.now(io);
    var end: std.Io.Timestamp = undefined;

    g.glCompileShader(vertexShader);
    end = std.Io.Clock.awake.now(io);
    var duration: i64 = std.Io.Duration.toMicroseconds(start.durationTo(end));
    // vertex shader compilation is ~600us
    std.debug.print("{s} compilation took {}us\n", .{ vertexShaderPath, duration });

    var vertexShaderCompiled: c_int = undefined;
    g.glGetShaderiv(vertexShader, g.GL_COMPILE_STATUS, &vertexShaderCompiled);
    if (!(vertexShaderCompiled != 0)) {
        printShaderCompileError(vertexShader);
        return 1;
    }
    var fragmentShaderSource: [*c]const u8 = @embedFile(fragmentShaderPath);
    // fragment shader operates, ahem, on fragments (of a screen) e.g. group of pixels
    const fragmentShader: c_uint = g.glCreateShader(g.GL_FRAGMENT_SHADER);
    // compilation process is the same as for vertexShader
    g.glShaderSource(fragmentShader, 1, &fragmentShaderSource, null);

    start = std.Io.Clock.awake.now(io);
    g.glCompileShader(fragmentShader);
    end = std.Io.Clock.awake.now(io);
    duration = std.Io.Duration.toMicroseconds(start.durationTo(end));
    // fragment shader compilation is ~150us
    std.debug.print("{s} compilation took {}us\n", .{ fragmentShaderPath, duration });

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
    return shaderProgram;
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

fn buildVAO(vertices: []f32, vertexAttribs: VertexAttribs) c_uint {
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
    // if our window is 800x600, this means that x == 0 will be translated to 400
    // and y == 0 will be translated to 300 - it's lerp

    // texture is a rectangle with coordinates from -1.0 to 1.0 on s (== x) and t (== y) axes.
    // lower left is (-1.0, -1.0), upper right is (1.0, 1.0)
    // each vertex is mapped to a position in a texture

    // copy data in the currently bound buffer
    // GL_STATIC_DRAW means - data will be set only once and used many times
    g.glBufferData(g.GL_ARRAY_BUFFER, @intCast(vertices.len * @sizeOf(f32)), vertices.ptr, g.GL_STATIC_DRAW);

    // tell OpenGL how to extract attributes (e.g. positions, colors, texture coordinates) from our data
    for (vertexAttribs.offsets, 0..) |offset, i| {
        const nextOffset = if (i + 1 < vertexAttribs.offsets.len) vertexAttribs.offsets[i + 1] else vertexAttribs.stride;
        const size = nextOffset - offset;
        g.glVertexAttribPointer(@intCast(i), // attribute position, same as location value in vertex shader
            @intCast(size), // attribute size, it's vec* in vertex shader
            g.GL_FLOAT, // attribute type
            g.GL_FALSE, // normalize data
            @intCast(vertexAttribs.stride * @sizeOf(f32)), // stride: distance between consecutive attributes
            @ptrFromInt(offset * @sizeOf(f32)) // offset of data in the buffer
        );
        g.glEnableVertexAttribArray(@intCast(i));
    }

    // unbind VBO
    g.glBindBuffer(g.GL_ARRAY_BUFFER, 0);
    // unbind current VAO
    g.glBindVertexArray(0);
    return VAO;
}

fn pointAtAngle(angle: f32, center: Point, radius: f32) Point {
    return .{
        .x = center.x + @cos(angle) * radius,
        .y = center.y + @sin(angle) * radius,
    };
}

pub fn main() !u8 {
    return hello_gl();
}
