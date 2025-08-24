#include <SDL.h>
#include <SDL_opengl.h>
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

    bool running = true;
    SDL_Event event;
    while (running) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) {
                running = false;
            }
        }

        // clear color buffers, this is OpenGL function
        // As I understand this is to reset OpenGL state machine on each frame
        // https://registry.khronos.org/OpenGL-Refpages/gl4/html/glClear.xhtml
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

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