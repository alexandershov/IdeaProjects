#version 330

// vignette shader - points that are more farther from the center are darker

// see aerial_perspective.fs for an explanation of raylib's built-in in/uniform/out parameters
in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

out vec4 finalColor;

void main() {
    vec4 color = texture(texture0, fragTexCoord) * colDiffuse * fragColor;
    // range of texture is [0; 1] in both directions, so center is (0.5, 0.5)
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(fragTexCoord, center);
    float maxDist = distance(center, vec2(1, 1));
    float minBrightness = 0.0;
    float maxBrightness = 1.0;
    // lerp in the vignette space based on the relative distance, dist/distance is between 0 and 1
    float brightness = mix(minBrightness, maxBrightness, 1 - dist/maxDist);
    finalColor = vec4(color.rgb * brightness, color.a);
}