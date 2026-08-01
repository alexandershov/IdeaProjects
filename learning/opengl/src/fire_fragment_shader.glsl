#version 410 core
in vec2 TexCoord;
in vec4 ParticleColor;

out vec4 Color;

uniform sampler2D ourTexture;

void main() {
  vec4 tex = texture(ourTexture, TexCoord);
  vec3 fireColor = mix(vec3(1.0, 0.1, 0.0, 1.0), vec3(1.0, 1.0, 0.3, 1.0), tex.r);
  Color = fireColor * ParticleColor;
}

