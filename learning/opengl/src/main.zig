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

// 4x MSAA, 4x is max MSAA on my machine
const MSAA = 4;

const HelloGLError = error{ShaderCompilationError};

const Args = struct {
    postProcessingFragmentShader: []const u8,
    quadTexture: []const u8,
    quadVertexShader: []const u8,
    quadFragmentShader: []const u8,
    drawTexturedTriangle: bool,
    drawTexturedQuad: bool,
    drawCircleGeometry: bool,
    drawSdf: bool,
    drawParticles: bool,
};

const Texture = struct {
    data: [*c]u8,
    width: c_int,
    height: c_int,
    numChannels: c_int,
    handle: u32,
};

const Vec4 = @Vector(4, f32);
const Vec2 = @Vector(2, f32);

const Particle = struct {
    position: Vec2,
    velocity: Vec2,
    color: Vec4,
    life: f32,

    pub fn init(random: std.Random) Particle {
        const c = 0.5 + random.float(f32) / 2.0; // range [0.5; 1)
        const px = (random.float(f32) / 10.0) - 0.05; // range [-0.05, 0.05)
        const py = (random.float(f32) / 10.0) - 0.05; // range [-0.05, 0.05)
        const vx = random.float(f32) / 100.0 - 0.005;  // range [-0.005, 0.005)
        const vy = 0.1 + random.float(f32) / 10.0;  // range [0.1, 0.2)
        return Particle{
            .position = Vec2{px, py},
            .velocity = Vec2{vx, vy},
            .color = Vec4{c, c, c, 1.0},
            .life = 1.0,
        };
    }

    pub fn tick(self: *Particle, dt: f32) void {
        self.life -= dt;
        if (self.life > 0) {
            self.position += self.velocity * Vec2{dt, dt};
            // particles become more transparent with time
            self.color[3] -= dt * 2.5;
        }
    }
};

fn hello_gl(initMinimal: std.process.Init.Minimal) !u8 {
    var argsIt = initMinimal.args.iterate();
    var ia: u32 = 0;
    var args = Args{
        .postProcessingFragmentShader = "",
        .quadTexture = "",
        .quadVertexShader = "src/quad_vertex_shader.glsl",
        .quadFragmentShader = "src/quad_fragment_shader.glsl",
        .drawTexturedTriangle = false,
        .drawTexturedQuad = true,
        .drawCircleGeometry = false,
        .drawSdf = false,
        .drawParticles = false,
    };
    // parse command line arguments
    while (argsIt.next()) |arg| {
        switch (ia) {
            0 => {}, // skip program name
            1 => {
                args.postProcessingFragmentShader = arg;
            },
            2 => {
                args.quadTexture = arg;
            },
            3 => {
                args.quadVertexShader = arg;
            },
            4 => {
                args.quadFragmentShader = arg;
            },
            5 => {
                args.drawTexturedTriangle = std.mem.eql(u8, arg, "true");
            },
            6 => {
                args.drawTexturedQuad = std.mem.eql(u8, arg, "true");
            },
            7 => {
                args.drawCircleGeometry = std.mem.eql(u8, arg, "true");
            },
            8 => {
                args.drawSdf = std.mem.eql(u8, arg, "true");
            },
            9 => {
                args.drawParticles = std.mem.eql(u8, arg, "true");
            },
            else => {
                return error.UnknownArgument;
            },
        }
        ia += 1;
    }

    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const gpa = debug_allocator.allocator();

    var threaded: std.Io.Threaded = .init(gpa, std.Io.Threaded.InitOptions{});
    defer threaded.deinit();
    const io = threaded.io();
    // by default you'll get jagged edges
    // so we need to enable antialiasing for a smoother edges
    // there are several ways to do antialiasing
    // early GPUs had something called SSAA (super sample antialiasing)
    // e.g. your render at 4x the resolution and then downscale
    // that's super expensive - you need to run fragment shaders 4x times
    // so multisample antialiasing (MSAA) appeared at the end of 90s/beginning of 2000s
    // each pixel has 4 (this is configurable) samples
    // fragment shader runs at a normal resolution, but can affect several samples
    // how many samples - depends on how many samples are inside of the triangle
    // then we determine the final color of the fragment by combining samples
    // if sample was not a part of any triangle then it will dilute fragment color
    // although we run fragment shader once for every fragment
    // we need to store color, depth, and stencil buffers for each sample
    // so we'll use more memory (4x more for 4x MSAA)

    // from the coding perspective:
    // we create a framebuffer with multisampled color, depth, and stencil buffers
    // we render out scene into this buffer
    // if we need to do quad-style post-processing, then we need to convert multisampled texture
    // to a regular texture, we do this with glBlitFramebuffer - and we need another framebuffer
    // that will contain a regular texture
    // we need this conversion, because texture() in GLSL can't work with multisampled textures
    _ = g.SDL_GL_SetAttribute(g.SDL_GL_MULTISAMPLEBUFFERS, 1);
    _ = g.SDL_GL_SetAttribute(g.SDL_GL_MULTISAMPLESAMPLES, MSAA);

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
    // enable MSAA
    g.glEnable(g.GL_MULTISAMPLE);
    // use alpha blending, required for antialiasing in sdf_fragment_shader.glsl to work
    // otherwise alpha value we set in sdf_fragment_shader.glsl is ignored
    g.glEnable(g.GL_BLEND);
    // aside from using alpha value, alpha blending can also combine current value at fragment with the new value at fragment
    // glBlendFunc is describing this combining
    // here it's lerp current_value = new_value * alpha + current_value * (1 - alpha)
    // alpha is alpha of new value, so if alpha is 1, then current_value is ignored
    // if alpha is 0, then new value is ignored
    // if alpha is in between, then we're getting a combination of two values
    g.glBlendFunc(g.GL_SRC_ALPHA, g.GL_ONE_MINUS_SRC_ALPHA);

    var maxMSAA: i32 = undefined;
    g.glGetIntegerv(g.GL_MAX_SAMPLES, &maxMSAA);
    // maxMSAA = 4 on my machine
    std.debug.print("maxMSAA = {}\n", .{maxMSAA});
    if (MSAA > maxMSAA) {
        std.debug.print("illegal MSAA = {}, maxMSAA is {}\n", .{ MSAA, maxMSAA });
        return 1;
    }

    const shaderProgram: c_uint = try buildShaderProgram(gpa, io, "./src/vertex_shader.glsl", "./src/fragment_shader.glsl");
    const quadShaderProgram: c_uint = try buildShaderProgram(gpa, io, args.quadVertexShader, args.quadFragmentShader);
    const sdfShaderProgram: c_uint = try buildShaderProgram(gpa, io, "./src/quad_vertex_shader.glsl", "./src/sdf_fragment_shader.glsl");
    const postProcessingShaderProgram: c_uint = try buildShaderProgram(gpa, io, "./src/quad_vertex_shader.glsl", args.postProcessingFragmentShader);
    const passThroughShaderProgram: c_uint = try buildShaderProgram(gpa, io, "./src/pass_through_vertex_shader.glsl", "./src/pass_through_fragment_shader.glsl");
    const particleShaderProgram: c_uint = try buildShaderProgram(gpa, io, "./src/particle_vertex_shader.glsl", "./src/particle_fragment_shader.glsl");

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
    g.glBindTexture(g.GL_TEXTURE_2D_MULTISAMPLE, texColorBuffer);
    g.glTexImage2DMultisample(g.GL_TEXTURE_2D_MULTISAMPLE, MSAA, g.GL_RGB, 800, 800, g.GL_TRUE);
    // unbind texture
    g.glBindTexture(g.GL_TEXTURE_2D_MULTISAMPLE, 0);
    // attach texture to the bound framebuffer
    g.glFramebufferTexture2D(g.GL_FRAMEBUFFER, g.GL_COLOR_ATTACHMENT0, g.GL_TEXTURE_2D_MULTISAMPLE, texColorBuffer, 0);

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
    g.glRenderbufferStorageMultisample(
        g.GL_RENDERBUFFER,
        MSAA, // number of samples
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

    var resolvedFbo: u32 = undefined;
    g.glGenFramebuffers(1, &resolvedFbo);
    g.glBindFramebuffer(g.GL_FRAMEBUFFER, resolvedFbo);
    defer g.glDeleteFramebuffers(1, &resolvedFbo);
    g.glBindFramebuffer(g.GL_FRAMEBUFFER, resolvedFbo);

    // create a texture that framebuffer will render to
    var resolvedTexColorBuffer: u32 = undefined;
    g.glGenTextures(1, &resolvedTexColorBuffer);
    g.glBindTexture(g.GL_TEXTURE_2D, resolvedTexColorBuffer);
    g.glTexImage2D(g.GL_TEXTURE_2D, 0, g.GL_RGB, 800, 800, 0, g.GL_RGB, g.GL_UNSIGNED_BYTE, null);
    // we'll apply kuwahara filter over this texture, so we don't need any interpolation
    g.glTexParameteri(g.GL_TEXTURE_2D, g.GL_TEXTURE_MIN_FILTER, g.GL_NEAREST);
    g.glTexParameteri(g.GL_TEXTURE_2D, g.GL_TEXTURE_MAG_FILTER, g.GL_NEAREST);
    // unbind texture
    g.glBindTexture(g.GL_TEXTURE_2D, 0);
    // attach texture to the bound framebuffer
    g.glFramebufferTexture2D(g.GL_FRAMEBUFFER, g.GL_COLOR_ATTACHMENT0, g.GL_TEXTURE_2D, resolvedTexColorBuffer, 0);

    // bind default framebuffer
    g.glBindFramebuffer(g.GL_FRAMEBUFFER, 0);
    // image coordinates is top-left, bottom-right, but texture coordinates are bottom-left, top-right
    // flip fixes that, so image is not upside down
    stb.stbi_set_flip_vertically_on_load(1);
    const texture = try loadTexture("src/wall.jpg", g.GL_LINEAR);
    defer stb.stbi_image_free(texture.data);

    const quadTexture = try loadTexture(args.quadTexture, g.GL_LINEAR);
    defer stb.stbi_image_free(quadTexture.data);

    const particleTexture = try loadTexture("src/fire_particle.png", g.GL_LINEAR);
    defer stb.stbi_image_free(particleTexture.data);

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

    const particleColorUniform: c_int = g.glGetUniformLocation(particleShaderProgram, "color");
    const particleOffsetUniform: c_int = g.glGetUniformLocation(particleShaderProgram, "offset");
    if (particleOffsetUniform == -1) {
        return error.OffsetUniformLocationError;
    }
    if (particleColorUniform == -1) {
        return error.ColorUniformLocationError;
    }

    var running: bool = g.true != 0;
    var event: g.SDL_Event = undefined;
    var redDelta: f32 = 0.0;
    var numUnaccountedFrames: usize = 0;
    var unaccountedFramesStartedAt: std.Io.Timestamp = std.Io.Clock.awake.now(io);
    const startedAt = std.Io.Clock.awake.now(io);
    var lastFrameStartedAt = std.Io.Clock.awake.now(io);
    var curFrameStartedAt = std.Io.Clock.awake.now(io);
    var dt: f32 = undefined;
    const MAX_PARTICLES = 1000;
    var numParticles: usize = 0;
    var particles: [MAX_PARTICLES]Particle = undefined;
    var prng = std.Random.DefaultPrng.init(100);
    const random = prng.random();
    while (running) {
        while (g.SDL_PollEvent(&event) != 0) {
            if (event.type == @as(g.Uint32, g.SDL_QUIT)) {
                running = g.false != 0;
            }
        }
        curFrameStartedAt = std.Io.Clock.awake.now(io);
        dt = @as(f32, @floatFromInt(lastFrameStartedAt.durationTo(curFrameStartedAt).toMicroseconds())) / 1000000.0;
        lastFrameStartedAt = curFrameStartedAt;

        // after this bind all read/write framebuffer operations will affect this framebuffer
        g.glBindFramebuffer(g.GL_FRAMEBUFFER, fbo);
        // clear color buffers, this is OpenGL function
        // As I understand this is to reset OpenGL state machine on each frame
        // https://registry.khronos.org/OpenGL-Refpages/gl4/html/glClear.xhtml
        g.glClearColor(0.2, 0.3, 0.3, 1.0);
        g.glClear(g.GL_COLOR_BUFFER_BIT | g.GL_DEPTH_BUFFER_BIT);
        g.glEnable(g.GL_DEPTH_TEST);
        if (args.drawTexturedTriangle) {
            g.glUseProgram(shaderProgram);
            // assigning uniform (aka global) value
            const colorDeltaLocation: c_int = g.glGetUniformLocation(shaderProgram, "colorDelta");
            // 4f is like hungarian notation, here it means assign vec4 to a location
            redDelta -= 0.0001;
            if (redDelta < -@as(f32, 0.999)) {
                redDelta = 0.0;
            }
            g.glUniform4f(colorDeltaLocation, redDelta, 0.0, 0.0, 0.0);
            g.glBindTexture(g.GL_TEXTURE_2D, texture.handle);
            // use VAO
            g.glBindVertexArray(triangleVAO);
            // draw triangles
            g.glDrawArrays(
                g.GL_TRIANGLES,
                0, // starting index of vertex array
                3, // how many vertices to draw, there are 3 vertices in a triangle
            );
        }

        if (args.drawCircleGeometry) {
            g.glUseProgram(passThroughShaderProgram);
            g.glBindVertexArray(circleVAO);
            g.glDrawArrays(g.GL_TRIANGLES, 0, numCircleTriangles * 3);
        }

        if (args.drawSdf) {
            g.glUseProgram(sdfShaderProgram);
            const durationFromStart = startedAt.durationTo(std.Io.Clock.awake.now(io));
            const timeUniform: c_int = g.glGetUniformLocation(sdfShaderProgram, "time");

            if (timeUniform == -1) {
                std.debug.print("can't find `time` uniform location in sdfShaderProgram\n", .{});
                return 1;
            }
            g.glUniform1f(timeUniform, @as(f32, @floatFromInt(durationFromStart.toMilliseconds())) / 1000.0);
            g.glBindVertexArray(quadVAO);
            g.glDrawArrays(
                g.GL_TRIANGLES,
                0, // starting index of vertex array
                6, // how many vertices to draw, there are 6 vertices in quad
            );
        }

        if (args.drawTexturedQuad) {
            g.glUseProgram(quadShaderProgram);
            g.glBindTexture(g.GL_TEXTURE_2D, quadTexture.handle);
            g.glBindVertexArray(quadVAO);
            g.glDrawArrays(
                g.GL_TRIANGLES,
                0, // starting index of vertex array
                6, // how many vertices to draw, there are 6 vertices in quad
            );
        }

        const emit = 5;
        for (0..emit) |_| {
            if (numParticles < MAX_PARTICLES) {
                particles[numParticles] = Particle.init(random);
                numParticles += 1;
            }
        }

        if (args.drawParticles and numParticles > 0) {
            var i = numParticles - 1;
            while (true) {
                particles[i].tick(dt);
                if (particles[i].life <= 0) {
                    particles[i] = particles[numParticles - 1];
                    numParticles -= 1;
                }
                if (i == 0) {
                    break;
                }
                i -= 1;
            }

            g.glBlendFunc(g.GL_SRC_ALPHA, g.GL_ONE);
            for (&particles) |*p| {
                g.glUseProgram(particleShaderProgram);
                g.glUniform2f(particleOffsetUniform, p.position[0], p.position[1]);
                g.glUniform4f(particleColorUniform, p.color[0], p.color[1], p.color[2], p.color[3]);
                g.glBindTexture(g.GL_TEXTURE_2D, particleTexture.handle);
                g.glBindVertexArray(quadVAO);
                g.glDrawArrays(
                    g.GL_TRIANGLES,
                    0, // starting index of vertex array
                    6, // how many vertices to draw, there are 6 vertices in quad
                );
            }
            g.glBlendFunc(g.GL_SRC_ALPHA, g.GL_ONE_MINUS_SRC_ALPHA);
        }

        // =====================
        // "draw" postprocessing
        // we wan't use multisample buffer in a shader, we need to resolve multisample buffer
        // into regular buffer
        g.glBindFramebuffer(g.GL_READ_FRAMEBUFFER, fbo);
        g.glBindFramebuffer(g.GL_DRAW_FRAMEBUFFER, resolvedFbo);
        // blit copies from fbo  to resolvedFbo
        g.glBlitFramebuffer(0, 0, 800, 800, 0, 0, 800, 800, g.GL_COLOR_BUFFER_BIT, g.GL_NEAREST);

        // render to a default buffer
        g.glBindFramebuffer(g.GL_FRAMEBUFFER, 0);
        g.glClearColor(1.0, 1.0, 1.0, 1.0);
        g.glClear(g.GL_COLOR_BUFFER_BIT);
        g.glUseProgram(postProcessingShaderProgram);
        // use VAO
        g.glBindVertexArray(quadVAO);
        g.glDisable(g.GL_DEPTH_TEST);
        g.glBindTexture(g.GL_TEXTURE_2D, resolvedTexColorBuffer);
        // draw triangles
        g.glDrawArrays(
            g.GL_TRIANGLES,
            0, // starting index of vertex array
            6, // how many vertices to draw, there are 6 vertices in quad
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
            std.debug.print("fps = {}\r", .{fps});
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

/// Compile shader at the specified path
fn compileShader(allocator: std.mem.Allocator, io: std.Io, path: []const u8, shaderType: u32) !c_uint {
    var sourceCode: []u8 = try std.Io.Dir.cwd().readFileAlloc(io, path, allocator, std.Io.Limit.unlimited);
    defer allocator.free(sourceCode);

    const shader: c_uint = g.glCreateShader(shaderType);
    const shaderLength: i32 = @intCast(sourceCode.len);
    // set source code to a shader, it takes an array of string, we pass just 1 string
    g.glShaderSource(shader, 1, &sourceCode.ptr, &shaderLength);

    var start: std.Io.Timestamp = std.Io.Clock.awake.now(io);

    g.glCompileShader(shader);

    const end: std.Io.Timestamp = std.Io.Clock.awake.now(io);
    const duration: i64 = std.Io.Duration.toMicroseconds(start.durationTo(end));

    std.debug.print("{s} compilation took {}us\n", .{ path, duration });

    var shaderCompiled: c_int = undefined;
    g.glGetShaderiv(shader, g.GL_COMPILE_STATUS, &shaderCompiled);
    if (shaderCompiled == 0) {
        printShaderCompileError(shader, path);
        return HelloGLError.ShaderCompilationError;
    }
    return shader;
}

fn buildShaderProgram(allocator: std.mem.Allocator, io: std.Io, vertexShaderPath: []const u8, fragmentShaderPath: []const u8) !c_uint {
    // vertex shader operates, ahem, on vertices
    const vertexShader = try compileShader(allocator, io, vertexShaderPath, g.GL_VERTEX_SHADER);
    // fragment shader operates, ahem, on fragments (of a screen) e.g. group of pixels
    const fragmentShader = try compileShader(allocator, io, fragmentShaderPath, g.GL_FRAGMENT_SHADER);

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

fn printShaderCompileError(shader: c_uint, path: []const u8) void {
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
    std.debug.print("{s} shader {s} failed to compile! {s}\n", .{ shaderType, path, shaderCompileError[0..@intCast(shaderCompileErrorLen)] });
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

fn loadTexture(path: []const u8, filter: i32) !Texture {
    var texture: Texture = undefined;
    texture.data = stb.stbi_load(
        @ptrCast(path),
        @ptrCast(&texture.width),
        @ptrCast(&texture.height),
        @ptrCast(&texture.numChannels),
        3, // force rgb
    );
    if (texture.data == null) {
        std.debug.print("could not load {s}\n", .{path});
        return error.CouldNotLoadTexture;
    }
    g.glGenTextures(1, &texture.handle);
    // bind texture to GL_TEXTURE_2D variable - usual binding stuff
    g.glBindTexture(g.GL_TEXTURE_2D, texture.handle);
    // we control what happens when texture coordinates are outside of the [0.0; 1.0]
    // here anything outside of the border will have border color - essentially it makes infinite borders
    // there's also possibility of g.GL_REPEAT to repeat texture
    g.glTexParameteri(g.GL_TEXTURE_2D, g.GL_TEXTURE_WRAP_S, g.GL_CLAMP_TO_EDGE);
    g.glTexParameteri(g.GL_TEXTURE_2D, g.GL_TEXTURE_WRAP_T, g.GL_CLAMP_TO_EDGE);
    // let's say we found a texel (pixel inside of the texture: "TEXture ELement") that represents our coordinates
    // we can control the color of this texel
    // GL_LINEAR will interpolate texel color based on the colors of its neighbours
    // there's also GL_NEAREST, that just takes the color of nearest texel
    // these are called texture filters and we can have different filters if our texture
    // was upscaled or downscaled
    g.glTexParameteri(g.GL_TEXTURE_2D, g.GL_TEXTURE_MIN_FILTER, filter);
    g.glTexParameteri(g.GL_TEXTURE_2D, g.GL_TEXTURE_MAG_FILTER, filter);
    g.glTexImage2D(
        g.GL_TEXTURE_2D, // operate on currently bound GL_TEXTURE_2D
        0, // no mipmap, mipmaps are kinda like LOD for textures - we can have smaller textures based on a surface of the polygon
        g.GL_RGB,
        texture.width,
        texture.height,
        0, // always 0, legacy
        g.GL_RGB,
        g.GL_UNSIGNED_BYTE,
        texture.data,
    );
    return texture;
}

fn pointAtAngle(angle: f32, center: Point, radius: f32) Point {
    return .{
        .x = center.x + @cos(angle) * radius,
        .y = center.y + @sin(angle) * radius,
    };
}

pub fn main(initMinimal: std.process.Init.Minimal) !u8 {
    return hello_gl(initMinimal);
}
