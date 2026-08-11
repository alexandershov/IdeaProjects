# Dear ImGui

## What is it?
Library for "Immediate mode GUI": which is game-engine-style way of writing GUIs: you render your GUI on every
frame. It's main use case is game-engine tools - since you already have game engine loop that renders frames.
"Immediate" in the name is opposed to "Retained" - traditional stateful approach to GUI 
(you create a button and it persists).

Immediate/Retained is analogous to old style OpenGL (glBegin/glVertex/glEnd) when you draw triangles directly vs
new style OpenGL when you create VAOs and render them by sending commands to OpenGL.

Note, that it doesn't mean that ImGui uses immediate rendering - it's not.

## Install
My Mac supports Metal 4:
```shell
$ system_profiler SPDisplaysDataType | rg -i metal
      Metal Support: Metal 4
```



## Usage
