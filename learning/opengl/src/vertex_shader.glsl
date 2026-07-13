//`version 410` means OpenGL 4.1.0
//`core` means using core platform
#version 410 core
// declare input: 3d-vector named aPos
layout (location = 0) in vec3 aPos;
// another input: 3d vector named aColor
layout (location = 1) in vec3 aColor;
// another input: 2d vector named aColor
layout (location = 2) in vec2 aTexCoord;

// output variable
out vec4 vertexColor;
out vec2 TexCoord;
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

    // scale by 2 and translate
    mat4 transform = mat4(
    2, 0, 0, 0.0,
    0, 2, 0, 2.0,
    0, 0, 2, 2.0,
    0, 0, 0, 1
    );
    vec3 tmpPos = aPos.zyx;
    // `tmpPos.zyx + 0.3` adds 0.3 to every component
    gl_Position = transform * vec4(tmpPos.zyx + 0.3, 1.0);
    // GLSL supports arithmetic operations on vectors
    vertexColor = vec4(aColor, 1.0f) + colorDelta;
    TexCoord = aTexCoord;
}
