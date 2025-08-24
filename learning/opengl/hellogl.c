// shut up mac warnings that OpenGL is deprecated
#define GL_SILENCE_DEPRECATION

// counterintuitively gl3.h also works with OpenGL 4.1
// IMPORTANT: don't include OpenGL/gl.h - it's a legacy header
// IMPORTANT: don't include SDL_opengl.h - it includes OpenGL/gl.h
#include <OpenGL/gl3.h>
#include <SDL.h>
#include <stdbool.h>

int main(int argc, char* argv[]) {
    SDL_Init(SDL_INIT_VIDEO);

    // use opengl 4.1
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);

    // core profile (i.e. "New way of doing OpenGL"): usage of glBegin/glEnd is forbidden
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

    // https://wiki.libsdl.org/SDL2/SDL_CreateWindow
    SDL_Window* window = SDL_CreateWindow(
        /* window title*/ "Testing OpenGL",
        /* x position of the window */ SDL_WINDOWPOS_CENTERED,
        /* y position of the window */ SDL_WINDOWPOS_CENTERED,
        /* width */ 800,
        /* height */ 600,
        /* window is usable with OpenGL */ SDL_WINDOW_OPENGL);

    // create OpenGL context for the window
    SDL_GLContext context = SDL_GL_CreateContext(window);

    // `version 410` means OpenGL 4.1.0
    // `core` means using core platform
    const char* vertexShaderSource = "#version 410 core\n"
    // declare input: 3d-vector named aPos
    "layout (location = 0) in vec3 aPos;\n"
    "void main()\n"
    "{\n"
    // gl_Position is an output
    // last argument in vec4(..., 1.0) is a something called Perspective Division
    // I don't know what it is
    "  gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);\n"
    "}\n";

    // vertex shader operates, ahem, on vertices
    unsigned int vertexShader = glCreateShader(GL_VERTEX_SHADER);
    // set source code to a shader, it takes an array of string, we pass just 1 string
    // NULL means that strings are null-terminated
    glShaderSource(vertexShader, 1, &vertexShaderSource, NULL);
    glCompileShader(vertexShader);
    int vertexShaderCompiled;
    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &vertexShaderCompiled);
    if (!vertexShaderCompiled) {
        printf("vertex shader failed to compile!\n");
    }

    // fragment shader outputs RGBA color. A stands for alpha (aka opacity)
    const char* fragmentShaderSource = "#version 410 core\n"
    "out vec4 Color;\n"
    "void main()\n"
    "{\n"
    " Color = vec4(1.0f, 0.0f, 0.0f, 1.0f);\n"
    "}\n";


    // fragment shader operates, ahem, on fragments (of a screen) e.g. group of pixels
    unsigned int fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    // compilation process is the same as for vertexShader
    glShaderSource(fragmentShader, 1, &fragmentShaderSource, NULL);
    glCompileShader(fragmentShader);
    int fragmentShaderCompiled;
    glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &fragmentShaderCompiled);
    if (!fragmentShaderCompiled) {
        printf("fragment shader failed to compile!\n");
    }

    // shader program contains several shaders
    unsigned int shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);

    int programLinked;
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &programLinked);
    if (!programLinked) {
        printf("shader program failed to link!\n");
    }

    // we don't need shader objects after we've linked them into a program
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);



    // Vertex Buffer Object, used to send vertices to GPU memory
    unsigned int VBO;
    // init 1 buffer object
    glGenBuffers(1, &VBO);

    // Vertex Array Object - holds VBO and its attribute configuration
    // Essentially it's a way to store VBO and its configuration done by *AttribPointer* functions
    // in one place and then use this place to draw
    // OpenGL core platform actually requires VAO to draw
    unsigned int VAO;
    // init 1 VAO object
    glGenVertexArrays(1, &VAO);

    // after call to glBindVertexArray VAO will remember *AttribPointer* functions
    glBindVertexArray(VAO);

    // from now on all operations on GL_ARRAY_BUFFER will operate on VBO
    // this is kinda like binding of variable (think `let` in Common Lisp)
    glBindBuffer(GL_ARRAY_BUFFER, VBO);

    // Coordinates are in Normalized Device Coordinates - range is [-1.0; 1.0]
    float vertices[] = {
    //  x     y     z
        0.0f, 0.0f, 0.0f,
        0.5f, 0.0f, 0.0f,
        0.5f, 0.5f, 0.0f,
    };

    // copy data in the currently bound buffer
    // GL_STATIC_DRAW means - data will be set only once and used many times
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    // tell OpenGL how to interpret our vector data (array of 9 floats)
    glVertexAttribPointer(
    /* attribute position, same as location value in vertex shader */ 0,
    /* attribute size, it's a vec3 in vertex shader */ 3,
    /* attribute type */ GL_FLOAT,
    /* normalize data */ GL_FALSE,
    /* stride: distance between consecutive attributes */ 3 * sizeof(float),
    /* offset of data in the buffer */ (void*)0);

    // enable attribute at location 0
    glEnableVertexAttribArray(0);
    // unbind VBO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    // unbind current VAO
    glBindVertexArray(0);

    bool running = true;
    SDL_Event event;
    while (running) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) {
                running = false;
            }
        }

        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        // clear color buffers, this is OpenGL function
        // As I understand this is to reset OpenGL state machine on each frame
        // https://registry.khronos.org/OpenGL-Refpages/gl4/html/glClear.xhtml
        glClear(GL_COLOR_BUFFER_BIT);

        glUseProgram(shaderProgram);
        // use VAO
        glBindVertexArray(VAO);

        // draw triangles
        glDrawArrays(
        GL_TRIANGLES,
        /* starting index of vertex array */ 0,
        /* how many vertices to draw, there are 3 vertices in a triangle */ 3);

        // update a window with OpenGL rendering
        // default OpenGL context uses double buffering, hence "swap" of the background/in-progress buffer
        // to the "active/screen" buffer
        SDL_GL_SwapWindow(window);
    }

    // clean up & exit
    SDL_GL_DeleteContext(context);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}