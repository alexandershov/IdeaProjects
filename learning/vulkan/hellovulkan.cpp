#include <iostream>

// with GLFW_INCLUDE_VULKAN glfw will include vulkan headers
#define GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>

int main() {
    // init window
    glfwInit();
    glfwWindowHint(GLFW_CLIENT_API, /* don't create OpenGL context */ GLFW_NO_API);
    // not resizable window, so we don't need to deal with resize
    glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);

    auto window = glfwCreateWindow(/* width */ 800, /* height */ 600, /* title */ "Hello Vulkan",
        /* monitor, like a display */ nullptr, /* OpenGL-specific */ nullptr);


    // main loop
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();
    }

    // deinit window
    glfwDestroyWindow(window);
    // deinit glfw
    glfwTerminate();

    std::cout << "done!\n";
}