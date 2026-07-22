#version 410 core
in vec4 Color;
out vec4 FragColor;

void main() {
     vec2 offset = vec2(300, 300);
     if (dot(gl_FragCoord.xy - offset, gl_FragCoord.xy - offset) < 100 * 100) {
     	discard;
     }
     
     FragColor = vec4(1.0, 0.0, 0.0, 0.0);
}

