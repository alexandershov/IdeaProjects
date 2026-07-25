#version 410 core
in vec4 Color;
in vec2 pos;
uniform float time;
out vec4 FragColor;

// like smoothstep, but not smooth
float steepstep(float a, float b, float x) {
  return clamp((x - a) / (b - a), 0.0, 1.0);
}

void main() {
  vec2 center = vec2(0.5, -0.5);
  float radius = 0.4;
  // sdf is a signed distance from current point to a surface of the circle
  // if current point is outside of the circle, then sdf is positive
  // if current point is inside of the cirlce, then sdf is negative
  // proof is simple: just consider these two cases and the math checks out
  // distance is a built-in glsl function
  // it's documented here: https://registry.khronos.org/OpenGL-Refpages/gl4/html/distance.xhtml
  // note that genType means Union[float, vec2, vec3, vec4]. It's a shorthand for "generic type"
  float sdf = distance(pos, center) - radius;
  // gpu executes fragment shaders in 2x2 quads
  // these quads are different from quads formed from 2 triangles
  // it's just a group of 4 pixels
  // let's say the current pixel is at the top left of the 2x2 quad
  // then abs(dFdx(sdf)) is essentially abs(sdf_value_at_pixel_to_the_right - sdf_value_at_current_pixel)
  // so dFdx gives you an access to the values at your quad neighbours
  // dFdy is the same but in vertical direction
  // actually GLSL has `fwidth` function that does abs(dFdx(sdf)) + abs(dFdy(sdf))
  // the job of fwidth is to provide a pixel-width estimate in our coordinates (remember, that distance is not pixels)
  // later we do antialiasing within 1 pixel of the border
  // it's actually L1 norm (aka Manhattan Distance)
  float aa = abs(dFdx(sdf)) + abs(dFdy(sdf));
  // smoothstep is like lerp but, ahem, smooth
  // if sdf <= -0.5 * aa, then result is 0
  // if sdf >= 0.5 * aa, then result is 1
  // if sdf is in between, then result is a smooth transition
  // smoothstep(-0.5 * aa, 0.5 * aa, sdf) is 0 inside and smoothly transitions to 1 outside
  // coverage is 1 inside and smoothly transitions to 0 outside
  // if sdf is inside of [-0.5 * aa; 0.5 * a], then we do antialiasing - this interval is ~1 pixel wide at the border
  // this is the exact location where we do antialiasing
  // if we change 0.5 to let's say 10, then we'll get blur effect instead of antialiasing
  // example of using time uniform and having dynamic halfWidth is commented out, because it's visually distracting
  // float halfWidth = 10 * abs(sin(time));
  float halfWidth = 0.5;
  float coverage = 1.0 - smoothstep(-halfWidth * aa, halfWidth * aa, sdf);

  if (coverage <= 0.0) {
    // if we're outside of the circle, then do nothing - there's nothing to antialias
    discard;
  }
  FragColor = vec4(0.0, 0.7, 0.0, 1.0 * coverage);
}

