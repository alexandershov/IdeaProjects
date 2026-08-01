#version 410 core
layout (location = 0) in vec4 vertex; // (vec2 position, vec2 texCoords)

out vec2 TexCoord;
out vec4 ParticleColor;

uniform vec2 offset;
uniform vec4 color;

void main() {
    gl_Position = vec4(vertex.xy + offset, 0.0, 1.0);
    TexCoord = vertex.zw;
    ParticleColor = color;
}
