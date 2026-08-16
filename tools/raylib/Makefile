CFLAGS += $(shell pkg-config --cflags raylib)
LDLIBS += $(shell pkg-config --libs raylib)

.PHONY: parallax_aerial_perspective vignette

parallax_aerial_perspective:
	clang -o parallax_aerial_perspective $(CFLAGS) $(LDLIBS) parallax_aerial_perspective.c && ./parallax_aerial_perspective


vignette:
	clang -o vignette $(CFLAGS) $(LDLIBS) vignette.c && ./vignette
