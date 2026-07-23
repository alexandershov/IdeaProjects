#version 410 core
in vec4 Color;
in vec2 pos;
out vec4 FragColor;

void main() {
  vec2 center = vec2(0.3, -0.3);
  float radius = 0.2;
  float distance = length(pos - center);
  if (distance > radius) {
    discard;
  }
  FragColor = vec4(0.0, 0.7, 0.0, 1.0);
}

