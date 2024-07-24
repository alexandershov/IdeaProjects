## Git

### Snapshots
Think of a commit as an immutable snapshot of your repo.

Commit has different fields (commit message, files/directories, author, parent commit). 
We can calculate hash (sha-1) of these fields and use this hash as a commit id.

sha-1 is a hash function that produces hash with the size of 160 bits 
(40 hex digits, as each digit represents 4 bits of information)

Essentially hash identifies every object (commit, file, directory) in git.

You can see hashes of commits in `git log` output.

You can inspect an object with `git cat-file -p` (`cat-file` is not a great name, `cat-object` would be better):
```shell
$ git cat-file -p 1750947b30386a6b963155a846e7887a5e92f42e

tree a35aa934b1a329d53ea5a2b197d319a887e00c91
parent eae5027bade4fc2788d09dff5790437ea4c96e7e
author alexandershov <email@example.com> 1721557026 +0200
committer alexandershov <email@example.com> 1721557026 +0200

unreal engine: describe C++ and blueprints
```

`tree` is a directory (looks like root directory of your repo for commit), you can also inspect it with `git cat-file -p`:
```shell
$ git cat-file -p a35aa934b1a329d53ea5a2b197d319a887e00c91

100644 blob d4b0c5a438082d5d997cc064844fc90917d9bac0	.gitignore
040000 tree a25dbfe47f48826778fc94f3133385a082c4d82a	learning
040000 tree 894f83638bfbcc16c0317fbd414e443b446fd25e	leetcode
040000 tree c800a3cc45efe9e9507fc6b4fc7352e5d9bcaff0	packaging
040000 tree 283a2bddb52f5bdf84bfd8594476cd6eff6d5082	sog-fortran
040000 tree 60c5a059c00b472b0046f4e151763abb52bd9083	sog-go-web
040000 tree f3542f805a17be8969314d8b96ee0a901b1a6b3b	sog-go
040000 tree bb3e80a91eb6f982b724b475eb3e07073438b059	sog-kotlin-web
040000 tree 436540fe85f0056a045793917f20d5843eaeb275	sog-kotlin
040000 tree a53fb1163a73f0fbbbccac7cf0ea473497d6c2e7	sog-python
040000 tree 4c06c8fb830d10425d61bc65472bd1832632365a	sog-react
040000 tree 5123794f5cbd1952fdab737c70d483edf80e5973	sog-svelte
040000 tree fa49799d37e2b413007e33189061f6d5f32597ac	sog-typescript
040000 tree 0bf36cdcbb0226524b54009d5f2631e2e25052c7	thames
040000 tree d3a656ea29055b7f900c7ff9aa610c9f595ab61e	tools
```

It contains directory data (including permissions like 0644) at a given snapshot.

`.gitignore` is a file (blob) and `cat-file` prints a content for it: 
```shell
$ git cat-file -p d4b0c5a438082d5d997cc064844fc90917d9bac0
*.iml
.idea
```

If we calculate sha-1 of this content with ...
```shell
$ git cat-file -p d4b0c5a438082d5d997cc064844fc90917d9bac0 | shasum -a 1
8ae0ac7309224916cd27a2a3f9ef80aaf105ec89  -
```

... then it won't match the file hash in git!

That happens because git actually calculates hash of "blob <content-size>\0<content>" and not just hash of "<content>"

Now hashes match (11 is a length of `.gitignore` in bytes):
```shell
printf "blob 11\0$(git cat-file -p d4b0c5a438082d5d997cc064844fc90917d9bac0)" | shasum -a 1
d4b0c5a438082d5d997cc064844fc90917d9bac0  -
```

git is essentially CAS (content addressable storage): if file doesn't change during the commit,
then its content will be stored only once as a blob.

Blobs are stored in `.git/objects`. Blobs are compressed with zlib.
```pycon
>>> import zlib
>>> import pathlib
>>> b = pathlib.Path('.git/objects/d4/b0c5a438082d5d997cc064844fc90917d9bac0').read_bytes()
>>> zlib.decompress
<built-in function decompress>
>>> zlib.decompress(b)
b'blob 11\x00*.iml\n.idea'
>>>
```

Since snapshots are primary data structure in git, this means that git needs to calculate diffs
dynamically when you want to see a diff.

So there are no "moves" of file in git, it's just delete and add. But diff can try to guess
that it was a move (if e.g. file content of deleted and added files match)

Git can optimize blob representation. Let's say you have a file of 1M lines, and you change just 1 line.
Storing 2 complete blobs for this change is expensive. So git can have smart blobs that store only deltas.
They are stored in `.git/objects/pack` directory. `git gc` can create these deltas (along with gc'ing old unreachable commits)

You can view unreachable objects with `git fsck`


### Branch
Branch has a name, latest commit, and history of the branch ("reference log" aka reflog).
So branch is just a pointer to some commit. It's stored in a file
```shell
$ cat .git/refs/heads/main

1750947b30386a6b963155a846e7887a5e92f42e
```

`1750947b30386a6b963155a846e7887a5e92f42e` is indeed a latest commit:
```shell
$ g log | head -1
commit 1750947b30386a6b963155a846e7887a5e92f42e
```

You can see the history of the branch with 
```shell
git reflog <branch>
```

If you skip the `<branch>`, then you'll reflog of HEAD.

You can change the current branch pointer with `git reset`:
```shell
$ git reset 75b3ed9
$ cat .git/refs/heads/main
75b3ed9aed61fdbdce3d472d3531923dd8004466
```

Even without `--hard` `reset` updates branch pointer to the specified commit.
You can `reset` in any direction (backward/forward)
Let's restore `main` to the latest commit with 
```shell
$ g reset 46535b1
$ cat .git/refs/heads/main
46535b12ee21d715e47bb8c94b3b69129e2e9018
```


### .git directory
Git stores its data in a `.git` directory.

`.git/HEAD` contains a reference to the current commit you're on.
It can be either a reference to a branch (e.g. `ref: refs/heads/main`) or a commit.
When it's a commit, then you get an infamous "detached HEAD state".

`.git/config` contains local config for the current repo. Global config is in `~/.gitconfig` 
`.git/config` contains config for remotes (e.g. uri for remote "origin").

Also, it can contain sections for branch tracking. E.g.
```text
[branch "main"]
remote = origin
merge = refs/heads/main
```

This means that branch `main` is set up to track remote `origin`.
So if you `git push` then git will be able to figure out that you want to push to `origin`.

Git also creates a remote tracking branch named `origin/main` 
that is automatically updated when you do `push|pull|fetch`.

Otherwise, it's just a normal branch.

Info on remote tracking branch is located at `.git/refs/remotes/{remoteName}/{branchName}`.
It's just a pointer to commit the same as e.g. `.git/refs/heads/main`.

Tags are stored in `.git/refs/tags` or `.git/packed-refs`.
Tag allows you to reference commit by human-readable name instead of a hash.