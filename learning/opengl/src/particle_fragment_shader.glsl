#version 410 core
in vec2 TexCoord;
in vec4 ParticleColor;

out vec4 Color;

uniform sampler2D fireSprite;

void main() {
  vec4 tex = texture(fireSprite, TexCoord);
  // fireSprite is a white sprite, so tex.r is intensity of it
  // if tex.r is 0, then we're at the least intense part (edge) = mix will return ~red
  // if tex.r is 1, then we're at the most intense part (core): mix will return ~yellow
  vec4 fireColor = mix(vec4(1.0, 0.1, 0.0, 1.0), vec4(1.0, 1.0, 0.3, 1.0), tex.r);
  Color = fireColor * ParticleColor;
}

