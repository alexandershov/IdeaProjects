#include <stdio.h>
#include <stdint.h>
#include <time.h>

int main() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    printf("ts.tv_nsec = %ld\n", ts.tv_nsec);
    long crash = 486;
    if (ts.tv_sec % 2 == 0) {
        crash++;
    }
    if (ts.tv_nsec % crash == 0) {
        int *p = NULL;
        // crash
        (*p) = 10;
    }
    return 0;
}
