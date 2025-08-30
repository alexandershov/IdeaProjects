## Vulkan

### What is it?

Vulkan is a cross-platform graphics API. It's a replacement for OpenGL.

It's more performant than OpenGL (if you know what you're doing) & more low-level. It doesn't rely on global state as OpenGL does, it lowers load on CPU,
also allows CPU to leverage multithreading.

Instead of GLSL that always needs compiling, it uses byte-code to represent shaders. 

### Install
I'm using macOS, there's no native Vulkan support, since Metal is _the_ graphics API on Apple.
But there's MoltenVK that translates Vulkan API to Metal.

Download it from https://vulkan.lunarg.com/sdk/home, unzip and run the app.

Similar to OpenGL Vulkan doesn't deal with the attaching context to window, so we'll need another library for that.
GLFW or SDL are both valid options for that:
```shell
brew install glfw
```

GLM is a library to do linear algebra:
```shell
brew install glm
```

### Running
```shell
make run
```

See [Makefile](./Makefile) for an exact command to run.
Source code is in the [hellovulkan.cpp](./hellovulkan.cpp)