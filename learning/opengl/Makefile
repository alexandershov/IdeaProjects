run:
	clang src/hellogl.c `pkg-config --cflags sdl2` -framework OpenGL `pkg-config --libs sdl2` -o /tmp/sdlgl
	/tmp/sdlgl

run-zig:
	zig run src/main.zig -framework OpenGL `pkg-config --libs sdl2`

