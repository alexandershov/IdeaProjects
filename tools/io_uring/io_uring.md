## io_uring

io_uring is relatively new feature in the Linux kernel that allows to do
async operations while minimizing number of syscalls.

It provides two ring queues.
One is submission queue. Another is completion queue.

Application submits tasks (read/write/poll/etc) to the submission queue.
Kernel checks submission queue for the tasks, asynchronously executes them,
and puts the completed tasks to the completion queue. 
Application checks completion queue for the completed tasks.

These queues are located in the shared memory. So putting and reading tasks
doesn't perform syscalls. That's the profit for the applications.

io_uring provides async interface not just for the network operations,
but also for reading local files and executing syscalls in general.

See an example of io_uring in action: [io_uring.c](./io_uring.c).

Here's how to run it.

Build docker image
```shell
docker build -t io_uring .
```

```shell
docker run -it -v .:/io_uring io_uring
```

Compile and run inside the container
```shell
cd /io_uring && gcc -o io_uring io_uring.c -luring
./io_uring
```

This will create file.txt. Write operation was dispatched with io_uring.