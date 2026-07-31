#version 410 core
in vec2 TexCoord;
out vec4 Color;

uniform sampler2D ourTexture;



void main() {
  Color = texture(ourTexture, TexCoord);
}

