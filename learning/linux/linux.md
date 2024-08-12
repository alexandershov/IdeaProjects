## Linux


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

Permissions string format is `[object_type][owner_read_permission][owner_write_permission][owner_execute_permission][group_read_permission][group_write_permission][group_execute_permission][others_read_permission][other_write_permission][other_execute_permission]`

So `-rwxr-xr-x` means that it's a file, owner can do everything, group and others can read and execute.

So permission 0644 means (underscores are just for readability) `110_100_100` or `rw-r--r--`.

### Proc filesystem

In `/proc/{pid}` you can see a bunch of useful info about the process with `pid`.

E.g. 
* `cmdline` that was used to start a process.
* `environ` contains environment variables