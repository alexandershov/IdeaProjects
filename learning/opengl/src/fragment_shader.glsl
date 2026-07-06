// fragment shader outputs RGBA color. A stands for alpha (aka opacity)
// this will be taken from the out of vertex shader
// if output of one shader matches type & name for the input another shader
// then the input and output become linked into pipeline
#version 410 core
in vec4 vertexColor;
out vec4 Color;
void main() {
   Color = vertexColor;
}

