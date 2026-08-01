#version 410 core
layout (location = 0) in vec2 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 TexCoord;
out vec4 ParticleColor;

uniform vec2 offset;
uniform vec4 color;

void main() {
  // scale so particles are small
  float scale = 0.005;
  gl_Position = vec4(aPos * scale + offset, 0.0, 1.0);
  TexCoord = aTexCoord;
  ParticleColor = color;
}
