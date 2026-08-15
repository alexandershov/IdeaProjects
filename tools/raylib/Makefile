CFLAGS += $(shell pkg-config --cflags raylib)
LDLIBS += $(shell pkg-config --libs raylib)

run:
	clang -o tutorial $(CFLAGS) $(LDLIBS) tutorial.c && ./tutorial