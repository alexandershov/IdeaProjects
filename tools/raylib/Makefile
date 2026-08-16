CFLAGS += $(shell pkg-config --cflags raylib)
LDLIBS += $(shell pkg-config --libs raylib)

run:
	clang -o parallax_aerial_perspective $(CFLAGS) $(LDLIBS) parallax_aerial_perspective.c && ./parallax_aerial_perspective