#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

extern char **environ;

int call() {
    int local_depth_2 = 0;
    printf("%p = stack address depth 2\n", &local_depth_2);
}

int main() {
    int local_depth_1;
    static int st;
    int *heap = (int *)malloc(sizeof(int));
    printf("%p = code address\n", &call);
    printf("%p = static address\n", &st);
    printf("%p = heap address\n", heap);
    printf("%p = stack address depth 1\n", &local_depth_1);
    call();
    printf("%p = environ address\n", environ);
    return 0;
}