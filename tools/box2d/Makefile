BOX2D_PREFIX := $(shell brew --prefix box2d)

run:
	clang -o tutorial -I"${BOX2D_PREFIX}"/include -L"${BOX2D_PREFIX}"/lib -lbox2d tutorial.c && ./tutorial