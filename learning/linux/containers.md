## Containers

### Setup

Install:
```shell
curl -fsSL https://get.docker.com -o docker.sh
sudo sh ./docker.sh
```

Start service and set permission for socket:
```shell
sudo systemctl start docker
chmod o+w /var/run/docker.sock
```

Start container:
```shell
docker run -it ubuntu:24.04
```

### How it works
Docker image is a tarball with all the files.
Docker unpacks this tarball into directory X and runs process for which X is root. 

When a process is started in a container it's actually a real process on a host.
You can run `sleep 3600` in a container and see that host also contains `sleep 3600` in `ps aux`.
But on a host this process has different pid.

Container process has a different root, cpu/memory limits (set via cgroups), its own network/pid namespaces,

E.g. to start a process in a new pid namespace you can:
```shell
# --pid makes a new pid namespace
# --fork makes unshare to fork a new process, this is required for --pid
# --mount-proc remounts /proc filesystem, so it reflects a new pid namespace (containing only pid == 1)
$ sudo unshare --pid --fork --mount-proc
# print current pid
$ echo $$
1
```

Current PID was 1, because we were running in a new pid namespace.

Root is set via `pivot_root` syscall. It's more secure version of `chroot`, because it mounts a new
filesystem at / for a container process. And you can't escape `pivot_root`.

Layers are separate tarballs - one tarball/directory for each layer. 
Layer has an id: hash of its content.

To "merge" them into the single fs 
overlayfs is used. It's kinda like ChainMap in Python. During the file lookup overlayfs will search files
starting with the top layer.

Writes are going to the temporary layer, that is getting deleted after container exits.
overlayfs actually takes upperdir - directory where the writes go.

