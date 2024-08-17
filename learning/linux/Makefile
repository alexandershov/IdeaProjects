strace-run:
	gcc -o src/hello src/hello.c && strace ./src/hello

memory-run:
	gcc -o src/memory src/memory.c && ./src/memory

fork-run-10000-times:
	for i in $$(seq 1 10000); do \
		python3 src/fork.py | head -3 | head -2 | tail -1; \
	done

dynamic-linking-run:
	gcc -o src/hello src/hello.c && ldd src/hello

static-linking-run:
	go build -o src/static src/static.go && (ldd src/static || true)