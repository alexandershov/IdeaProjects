## Containers

### TLDR
When you run a process in a "container", it's just a process running in separate pid/network/etc namespaces,
in a separate root, with an overlayfs, and possibly with cpu/memory limitation based on cgroups.

For each process running in a "container" there's a real process in Linux. Containers are not magic.
They just use linux features.

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

Here's how to create overlayfs:
```shell
mkdir first second writedir workdir merged
echo from_first > first/file.txt
echo from_second > second/file.txt
echo 2nd > second/only.txt
# translation: lowerdir - readonly dirs
# first takes priority over second, because it comes before second in lowerdir lists
# upperdir - writes go here
# workdir - needs for renames/deletes to work, managed by fs
sudo mount -t overlay overlay -o lowerdir=first:second,upperdir=writedir,workdir=workdir merged
```

Now let's use overlayfs:
```shell
# first wins
$ cat merged/file.txt
from_first

# if there's nothing in first, then second wins
$ cat merged/only.txt
2nd

$ echo from_merged > merged/file.txt
# writes go to writedir
$ cat writedir/file.txt
from_merged

# writes don't affect lowerdirs
$ cat first/file.txt
from_first
$ cat second/file.txt
from_second
```
