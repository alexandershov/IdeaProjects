## OpenGL

### What is it?
OpenGL is a graphices API.
It got no new versions or changes in spec since 2017, [Vulkan](https://en.wikipedia.org/wiki/Vulkan) is replacement.
Latest verion is 4.6.

It's officially deprecated on Apple platforms in favor of Metal.
Although OpenGL is deprecated on macOS, it's still available (versions 3.2 & 4.1)

### Usage
SDL is a library to simplify multimedia stuff, so I'm using it.

Install:
```shell
brew install sdl2 pkg-config
```

`pkg-config` helps to configure compiler/linker flags.

See [hellogl.c](./hellogl.c) for an example.

Run it with `make hellogl`

### Fundamentals

OpenGL is just a spec of API, implementation of OpenGL is on graphics card manufacturers.

OpenGL is a big state machine: you can manipulate its state using functions.

The job of OpenGL is to draw stuff on screen, this is done by a graphics pipeline.
There are different stages in the pipeline, on a high-level:
* you provide vertices in a 3D-space
* vertex shaders transform 3D coordinates into coordinate on screen
* rasterization outputs stuff on a screen
* fragment shaders (aka pixel shaders) can control the color of each pixel on screen

Shaders are small programs written in a special language GLSL (GL Shader Language) and they run on a GPU. 