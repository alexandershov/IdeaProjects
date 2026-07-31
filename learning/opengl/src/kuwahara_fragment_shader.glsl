#version 410 core
in vec2 TexCoord;
out vec4 Color;

uniform sampler2D ourTexture;

// convert rgb to a single value, so kuwahara will work
float luminance(vec4 c) {
  //                     r       g       b
  return dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
}

// returns (mean, stddev) for a single quadrant with the given size
vec2 kuwahara(vec2 lowerLeft, vec2 texelSize, int quadrantSize) {
  float mean;
  float stddev;
  for (int x = 0; x < quadrantSize; x++) {
    for (int y = 0; y < quadrantSize; y++) {
      vec2 coord = lowerLeft + vec2(x * texelSize.x, y * texelSize.y);
      vec4 color = texture(ourTexture, coord);
      mean += luminance(color) / (quadrantSize * quadrantSize);
    }
  }
  for (int x = 0; x < quadrantSize; x++) {
    for (int y = 0; y < quadrantSize; y++) {
      vec2 coord = lowerLeft + vec2(x * texelSize.x, y * texelSize.y);
      vec4 color = texture(ourTexture, coord);
      stddev += pow(luminance(color) - mean, 2) / (quadrantSize * quadrantSize);
    }
  }
  stddev = sqrt(stddev);
  return vec2(mean, stddev);
}

void main() {
  int quadrantSize = 9;
  vec2 texelSize = 1.0 / textureSize(ourTexture, 0); // 0 is level of details, we don't have any

  // calculate mean & stddev for 4 quadrants
  vec2 lowerLeft = kuwahara(TexCoord - (quadrantSize - 1) * texelSize, texelSize, quadrantSize);
  vec2 topRight = kuwahara(TexCoord, texelSize, quadrantSize);
  vec2 topLeft = kuwahara(TexCoord - (quadrantSize - 1) * vec2(texelSize.x, 0), texelSize, quadrantSize);
  vec2 lowerRight = kuwahara(TexCoord - (quadrantSize - 1) * vec2(0, texelSize.y), texelSize, quadrantSize);

  float minStddev = min(min(lowerLeft.y, topRight.y), min(lowerRight.y, topLeft.y));
  vec3 c3;
  if (lowerLeft.y == minStddev) {
    c3 = vec3(lowerLeft.x);
  } else if (lowerRight.y == minStddev) {
    c3 = vec3(lowerRight.x);
  } else if (topRight.y == minStddev) {
    c3 = vec3(topRight.x);
  } else {
    c3 = vec3(topLeft.x);
  }
  Color = vec4(c3, 1.0);
}