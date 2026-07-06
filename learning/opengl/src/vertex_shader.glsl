//`version 410` means OpenGL 4.1.0
//`core` means using core platform
#version 410 core
// declare input: 3d-vector named aPos
layout (location = 0) in vec3 aPos;
// another input: 3d vector named aColor
layout (location = 1) in vec3 aColor;
// output variable
out vec4 vertexColor;
// uniform is like a global variable
uniform vec4 colorDelta;
void main() {
    // gl_Position is an output
    // last argument in vec4(..., 1.0) is a something called Perspective Division
    // I don't know what it is
    // aPos.xyz is like `*[aPos.x, aPos.y, aPos.z]` in python
    // it's called swizzling
    // you can also create new vectors from it and rearrange components
    // here I rearrange components twice just for the kicks of it
    vec3 tmpPos = aPos.zyx;
    gl_Position = vec4(tmpPos.zyx, 1.0);
    // GLSL supports arithmetic operations on vectors
    vertexColor = vec4(aColor, 1.0f) + colorDelta;
}
