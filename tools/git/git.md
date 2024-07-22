## Git

### Snapshots
Think of a commit as an immutable snapshot of your repo.

Commit has different fields (commit message, files/directories, author, parent commit). 
We can calculate hash (sha-1) of these fields and use this hash as a commit id.

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

It contains directory data at a given snapshot.

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

Since snapshots are primary data structure in git, this means that git needs to calculate diffs
dynamically when you want to see a diff.

So there are no "moves" of file in git, it's just delete and add. But diff can try to guess
that it was a move (if e.g. file content of deleted and added files match)


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