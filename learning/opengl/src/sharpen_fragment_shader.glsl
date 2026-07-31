#version 410 core
in vec2 TexCoord;
out vec4 Color;

uniform sampler2D ourTexture;

void main() {
  vec2 texelSize = 1.0 / textureSize(ourTexture, 0); // 0 is level of details, we don't have any
  float kernel[9]  = float[](
  	-1, -1, -1,
	-1, 9, -1,  // 9 is center
	-1, -1, -1
  );
  vec3 color = vec3(0.0);
  // a bit weird loop conditions, so it matches order in kernel
  int ki = 0;
  for (int dy = 1; dy >= -1; dy--) {
      for (int dx = -1; dx < 2; dx++) {
      	  vec2 offset = vec2(dx * texelSize.x, dy * texelSize.y);
	  vec4 curColor = texture(ourTexture, TexCoord + offset);
	  color += curColor.xyz * kernel[ki];
	  ki++;
      }
  }
  
  Color = vec4(color, 1.0);
}
