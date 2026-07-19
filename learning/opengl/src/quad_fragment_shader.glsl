#version 410 core
in vec2 TexCoord;
out vec4 Color;

uniform sampler2D ourTexture;

void main() {
  // we jump through the hoops of rendering via framebuffer texture, so we can add easily add post-processing in a second pass
  // e.g. render in grayscale
  vec4 FragColor = texture(ourTexture, TexCoord);
  float average = 0.2126 * FragColor.r + 0.7152 * FragColor.g + 0.0722 * FragColor.b;
  // grayscale is commented out, so we'll see more colorful output
  // Color = vec4(average, average, average, 1.0);
  Color = FragColor;
}

