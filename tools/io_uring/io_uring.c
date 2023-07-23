#define _GNU_SOURCE
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <liburing.h>

int main() {
    struct io_uring ring;

    // initialize ring queue of size 8
    io_uring_queue_init(8, &ring, 0);

    int fd = open("file.txt", O_WRONLY | O_CREAT, 0644);
    if (fd < 0) {
        perror("open");
        return 1;
    }

    // sqe is submission queue
    struct io_uring_sqe *sqe = io_uring_get_sqe(&ring);
    if (!sqe) {
        fprintf(stderr, "Could not get SQE.\n");
        return 1;
    }

    char *str = "Hello, io_uring world!";
    // put `write` task to the submission queue
    io_uring_prep_write(sqe, fd, str, strlen(str), 0);
    io_uring_sqe_set_data(sqe, str);

    io_uring_submit(&ring);

    // completion queue
    struct io_uring_cqe *cqe;
    // will block if queue is we skip io_uring_submit
    int ret = io_uring_wait_cqe(&ring, &cqe);
    if (ret < 0) {
        fprintf(stderr, "Could not wait for completion.\n");
        return 1;
    }

    if (cqe->res < 0) {
        fprintf(stderr, "Async write failed.\n");
        return 1;
    }

    io_uring_cqe_seen(&ring, cqe);
    close(fd);
    io_uring_queue_exit(&ring);

    return 0;
}
