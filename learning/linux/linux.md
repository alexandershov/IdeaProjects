## Linux

### Run Linux on Mac M2

I tried apple-silicon version of virtual box is 7.0.8beta, it didn't work.

[UTM](https://mac.getutm.app) and ubuntu 24.04 for ARM worked with some tweaks:

* Error "Display Output is not active" is fixed by choosing virtio-ramfb-gl (GPU Supported) option
* Some parts of keyboard were not working when Ubuntu asked for a username during installation.
  What worked for me was choosing keyboard setup during ubuntu installation, then
  ubuntu selected I_dont_remember_WITH_DEAD_KEYS and keyboard started working.
* After installation was completed, I needed to remove ISO from VM settings and start the VM again.

To share a directory, execute this inside of VM:

```shell
sudo mkdir [mount point]
$ sudo mount -t 9p -o trans=virtio share [mount point] -oversion=9p2000.L
```

Or add this line to `/etc/fstab` and reboot VM:

```text
share	[mount point]	9p	trans=virtio,version=9p2000.L,rw,_netdev,nofail	0	0
```

### File permissions

```shell
root@ba902351e8af:/# ls -l /bin/ | head -3
total 20284
-rwxr-xr-x 1 root root     43184 Feb  7  2022 [
-rwxr-xr-x 1 root root     10400 Feb 21  2022 addpart
```

first `root` is file owner.
second `root` is file owner's group.

`r` stands for Read permissions
`w` stands for Write permissions
`x` stands for eXecute permissions.

Permissions are split into 3 groups: owner, owner group, and everybody else.
`-` is overloaded. `-` as a first character means that it's a file.
But `-` in other places means that someone don't have this permission.

Permissions string format
is `[object_type][owner_read_permission][owner_write_permission][owner_execute_permission][group_read_permission][group_write_permission][group_execute_permission][others_read_permission][other_write_permission][other_execute_permission]`

So `-rwxr-xr-x` means that it's a file, owner can do everything, group and others can read and execute.

So permission 0644 means (underscores are just for readability) `110_100_100` or `rw-r--r--`.

### Proc filesystem

In `/proc/{pid}` you can see a bunch of useful info about the process with `pid`.

E.g.

* `cmdline` that was used to start a process.
* `environ` contains environment variables