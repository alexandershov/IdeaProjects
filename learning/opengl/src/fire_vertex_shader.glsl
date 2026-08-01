#version 410 core
layout (location = 0) in vec2 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 TexCoord;
out vec4 ParticleColor;

uniform vec2 offset;
uniform vec4 color;

void main() {
    gl_Position = vec4(aPos + offset, 0.0, 1.0);
    TexCoord = aTexCoord;
    ParticleColor = color;
}
