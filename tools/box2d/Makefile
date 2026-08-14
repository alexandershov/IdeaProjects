BOX2D_PREFIX := $(shell brew --prefix box2d)
RAYLIB_FLAGS := $(shell pkg-config --cflags --libs raylib)

run:
	clang -o tutorial -I"${BOX2D_PREFIX}"/include ${RAYLIB_FLAGS} -L"${BOX2D_PREFIX}"/lib -lbox2d tutorial.c && ./tutorial