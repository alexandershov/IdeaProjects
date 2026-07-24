#version 410 core
in vec4 Color;
in vec2 pos;
out vec4 FragColor;

void main() {
  vec2 center = vec2(0.3, -0.3);
  float radius = 0.2;
  // sdf is a signed distance from current point to a surface of the circle
  // if current point is outside of the circle, then sdf is positive
  // if current point is inside of the cirlce, then sdf is negative
  // proof is simple: just consider these two cases and the math checks out
  float sdf = distance(pos, center) - radius;
  // gpu executes fragment shaders in 2x2 quads
  // these quads are different from quads formed from 2 triangles
  // it's just a group of 4 pixels
  // let's say the current pixel is at the top left of the 2x2 quad
  // then abs(dFdx(sdf)) is essentially abs(sdf_value_at_pixel_to_the_right - sdf_value_at_current_pixel)
  // so dFdx gives you an access to the values at your quad neighbours
  // dFdy is the same but in vertical direction
  // actually GLSL has `fwidth` function that does abs(dFdx(sdf)) + abs(dFdy(sdf))
  float aa = abs(dFdx(sdf)) + abs(dFdy(sdf));
  // smoothstep is like lerp but, ahem, smooth
  // if sdf <= -0.5 * aa, then result is 0
  // if sdf >= 0.5 * aa, then result is 1
  // if sdf is in between, then result is a smooth transition
  // smoothstep(-0.5 * aa, 0.5 * aa, sdf) is 0 inside and smoothly transitions to 1 outside
  // coverage is 1 inside and smoothly transitions to 0 outside
  float coverage = 1.0 - smoothstep(-0.5 * aa, 0.5 * aa, sdf);

  if (coverage <= 0.0) {
    // if we're outside, then do nothing - there's nothing to antialias
    discard;
  }
  FragColor = vec4(0.0, 0.7, 0.0, 1.0 * coverage);
}

