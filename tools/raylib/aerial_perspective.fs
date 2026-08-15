#version 330

// predefined inputs for raylib fragment shaders
in vec2 fragTexCoord;
in vec4 fragColor;

// predefined uniforms for raylib fragment shaders
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// predefined output for raylib fragment shaders
out vec4 finalColor;

void main() {
    vec4 color = texture(texture0, fragTexCoord) * colDiffuse * fragColor;
    finalColor = color;
}