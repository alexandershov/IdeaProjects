#version 330

// see aerial_perspective.fs for an explanation of raylib's built-in in/uniform/out parameters

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

out vec4 finalColor;

void main() {
    vec4 color = texture(texture0, fragTexCoord) * colDiffuse * fragColor;
    finalColor = color;
}