#version 410 core
in vec4 Color;
in vec2 pos;
uniform float time;
out vec4 FragColor;

// like smoothstep, but not smooth
float steepstep(float a, float b, float x) {
  // clamp(x, min, max) ensures that min <= x <= max, it's essentially
  // if x > max: return max
  // if x < min: return min
  // else: return x
  return clamp((x - a) / (b - a), 0.0, 1.0);
}

float sdfSphere(vec2 pos, vec2 center, float radius) {
  // sdf is a signed distance from current point to a surface of the circle
  // if current point is outside of the circle, then sdf is positive
  // if current point is inside of the cirlce, then sdf is negative
  // proof is simple: just consider these two cases and the math checks out
  // distance is a built-in glsl function
  // it's documented here: https://registry.khronos.org/OpenGL-Refpages/gl4/html/distance.xhtml
  // note that genType means Union[float, vec2, vec3, vec4]. It's a shorthand for "generic type"
  return distance(pos, center) - radius;
}

float sdfUnion(float first, float second) {
  // union (kinda) of two sdfs
  // #1 first is outside, second is outside: we're outside of union and the minimum distance is well, minimum of two distances
  // #2 either first or second is inside, then min will give us negative answer
  // min gives us mathematically correct answer only for the #1; for #2 it gives us the correct sign
  // if either first or second is 0 in #1, then we'd still get correct answer (0)
  // if either first or second is 0 in #1, then we'd still get correct answer (negative sign, because we're inside of the union)
  return min(first, second);
}

float sdfIntersction(float first, float second) {
  // intersection (kinda) of two sdfs
  // #1 first is inside, second is inside: both are negative, max will give us the closest
  // #2 either first or second is outside: max will give us positive answer
  // max gives us mathematically correct answer only for the #1; for #2 it gives us the correct sign
  // if either first or second is 0 in #1, then we'd still get correct answer (0)
  // if either first or second is 0 in #1, then we'd still get correct answer (positive sign, because we're outside of the intersection)
  return max(first, second);
}

float sdfDifference(float first, float second) {
  // TODO: implement it
  return first + second;
}

float sdfAABB(vec2 pos, vec2 bottomLeft, vec2 topRight) {
  // sdf to AABB (axis-aligned bounding box)
  // we calculate horizontal and vertical sdfs
  // if we're inside then we take maximum of those (maximum because sdf is negative inside)
  // if we're outside on just 1 dimension, then we take minimum on this direction
  // if we're outside on both dimensions, then we take L2 norm
  // idea: solve for line and then do union of sdfs
  float dleft = lowerLeft.x - pos.x;
  float dright = pos.x - topRight.x;
  float dbottom = lowerLeft.y - pos.y;
  float dtop = pos.y - topRight.y;
  if (dleft <= 0 && dright <= 0 && dbottom <= 0 && dtop <= 0) {
    // we're inside, take maximum, because sdfs are negative inside
    return max(dleft, dright, dbottom, dtop);
  }
  
}

void main() {
  // float sdf = sdfSphere(pos, vec2(0.5, -0.5), 0.4);
  float sdf = sdfAABB(pos, vec2(0.3, 0.3), vec2(0.5, 0.5));
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
  // example of using time uniform and having dynamic halfWidth is immediately overriden in the next line, because
  // it's visually distracting
  // if we don't use the uniform `time`, then it will be optimized away, and glGetUniformLocation will return -1
  float halfWidth = 10 * abs(sin(time));
  halfWidth = 0.5;
  float coverage = 1.0 - smoothstep(-halfWidth * aa, halfWidth * aa, sdf);

  if (coverage <= 0.0) {
    // if we're outside of the shape, then do nothing - there's nothing to antialias
    discard;
  }
  // for points that are inside the shape apply alpha to antialias
  FragColor = vec4(0.0, 0.7, 0.0, 1.0 * coverage);
}

