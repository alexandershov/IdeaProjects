# Dear ImGui

## What is it?
Library for "Immediate mode GUI": which is game-engine-style way of writing GUIs: you render your GUI on every
frame. It's main use case is game-engine tools - since you already have game engine loop that renders frames.
"Immediate" in the name is opposed to "Retained" - traditional stateful approach to GUI 
(you create a button and it persists).

Immediate/Retained is analogous to old style OpenGL (glBegin/glVertex/glEnd) when you draw triangles directly vs
new style OpenGL when you create VAOs and render them by sending commands to OpenGL.

Note, that it doesn't mean that ImGui uses immediate rendering - it does not.

One advantage of ImGui is that you don't need to save state of the widgets: you just have your own state 
and you pass this state to widgets as you go. 

ImGui is rendering-agnostic and supports bunch of backends: if you can render textured triangles, then you can
use ImGui.

## Install
Just checkout imgui with git:
```shell
g clone https://github.com/ocornut/imgui.gi
```


## Usage
Run an example. Example source code is in [main.mm](./main.mm). `.mm` extension is Objective-C++ extension.
```shell
IMGUI_PATH=path/to/imgui/checkout make
```