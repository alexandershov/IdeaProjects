// fragment shader outputs RGBA color. A stands for alpha (aka opacity)
// this will be taken from the out of vertex shader
// if output of one shader matches type & name for the input another shader
// then the input and output become linked into pipeline
// in our case output variable vertexColor from vertex shader will be an input for vertexColor in fragment shader
#version 410 core
in vec4 vertexColor;
in vec2 TexCoord;
out vec4 Color;
// sampler2D is texture data type
uniform sampler2D ourTexture;
void main() {
   // rgb is the same as xyz, works on any vector
  // Color = vec4(vertexColor.rgb, 1.0);
  // gl_FragCoord holds screen coordinates of the current fragment
  // here we color everything to the right of x == 700 with red
  // if (gl_FragCoord.x > 700) {
  //Color = vec4(1.0, 0.0, 0.0, 1.0);
  //}
  // texture is GLSL built-in that does texturing for fragments
  // TexCoord will be interpolated coordinates - the fact that we have only 3 vertices
  // doesn't mean that we'll call fragment shader 3 times - we'll call it for every fragment (== pixel, more or less)
  Color = texture(ourTexture, TexCoord);
}

