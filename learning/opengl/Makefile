# to override variable values run it like this:
# make run POST_PROCESSING_SHADER=./src/kuwahara_fragment_shader.glsl

POST_PROCESSING_SHADER ?= ./src/sharpen_fragment_shader.glsl
QUAD_TEXTURE ?= ./src/barbara.jpg
QUAD_VERTEX_SHADER ?= ./src/textured_quad_vertex_shader.glsl
QUAD_FRAGMENT_SHADER ?= ./src/textured_quad_fragment_shader.glsl
DRAW_TEXTURED_TRIANGLE ?= false
DRAW_TEXTURED_QUAD ?= true
DRAW_CIRCLE_GEOMETRY ?= false
DRAW_SDF ?= false
DRAW_PARTICLES ?= false

run:
	zig run src/main.zig src/stb_image.c -I src -framework OpenGL `pkg-config --libs sdl2` -- "$(POST_PROCESSING_SHADER)" "$(QUAD_TEXTURE)" "$(QUAD_VERTEX_SHADER)" "$(QUAD_FRAGMENT_SHADER)" "$(DRAW_TEXTURED_TRIANGLE)" "$(DRAW_TEXTURED_QUAD)" "$(DRAW_CIRCLE_GEOMETRY)" "$(DRAW_SDF)" "$(DRAW_PARTICLES)"

