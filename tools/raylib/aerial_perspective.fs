#version 330

// predefined inputs for raylib fragment shaders
in vec2 fragTexCoord;
in vec4 fragColor;

// predefined uniforms for raylib fragment shaders
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// our custom uniform
uniform float atmosphereCoeff;

// predefined output for raylib fragment shaders
out vec4 finalColor;

void main() {
    // light blue
    vec4 atmosphere = vec4(0.65, 0.78, 0.88, 1.0);
    vec4 color = texture(texture0, fragTexCoord) * colDiffuse * fragColor;
    finalColor = mix(color, atmosphere, atmosphereCoeff);
}