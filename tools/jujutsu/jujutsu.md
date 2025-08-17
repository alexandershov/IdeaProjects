## Jujutsu

Jujutsu is a source control system. It uses git as a storage backend, so you can use it with all of 
the existing ecosystem around git (e.g. github) and its CLI is nicer.

### Install
```shell
brew install jj
```

Configure name & email similar to git:
```shell
jj config set --user user.name <NAME>
jj config set --user user.email <EMAIL>
```

### Usage
You can clone an existing git repository with it:
```shell
jj git clone --colocate https://github.com/alexandershov/IdeaProjects.git
```

Alongside the usual `.git` directory this will create `.jj` directory.

Create a new revision on top of main:
```shell
jj new main
```

Log:
```shell
jj log
@  zpuvqxzw codumentary.com@gmail.com 2025-08-17 10:13:11 56740a05
│  (empty) (no description set)
◆  mvuxrvnt codumentary.com@gmail.com 2025-08-16 12:36:31 main git_head() 83adab95
│  pgn_parser: make getRanges compile
```

`@` refers to a current revision.

There's no staging area in `jj` and you can just add/edit some files, revision will reflect these changes:
```shell
$ echo haha > test.txt
$ jj show @
Commit ID: 85b11758ef533b4cdc2dc8c96550c3da8e8e0cd7
Change ID: zpuvqxzwtvqtpxzuqxzmxynnxmslynst
Author   : alexandershov <codumentary.com@gmail.com> (2025-08-17 10:16:35)
Committer: alexandershov <codumentary.com@gmail.com> (2025-08-17 10:17:30)

    (no description set)

Added regular file test.txt:
        1: haha
(END)
```

Under the hood we actually already have a git commit.
If you change a file, then we'll get another commit id:
```shell
$ echo haha >> test.txt
$ jj show @
Commit ID: 1062e08b3ceb55fde0220755fd81568208902b56
Change ID: zpuvqxzwtvqtpxzuqxzmxynnxmslynst
Author   : alexandershov <codumentary.com@gmail.com> (2025-08-17 10:16:35)
Committer: alexandershov <codumentary.com@gmail.com> (2025-08-17 10:19:47)

    (no description set)

Added regular file test.txt:
        1: haha
        2: haha
```

Note that "Commit ID" changed (it's git commit id), but "Change ID" stays the same (it's jj id.)

We can add a message to our current change:
```shell
jj describe -m "test change"
```

We have bookmarks instead of git branches. They're kinda like pointers to specific revisions:
```shell
$ jj bookmark create test-change -r @
Created 1 bookmarks pointing to zpuvqxzw 21b6b955 test-change | test change
$ jj log
@  zpuvqxzw codumentary.com@gmail.com 2025-08-17 10:21:31 test-change 21b6b955
│  test change
◆  mvuxrvnt codumentary.com@gmail.com 2025-08-16 12:36:31 main git_head() 83adab95
│  pgn_parser: make getRanges compile
```

Let's add another revision:
```shell
echo "first" > test.txt
echo "second" >> test.txt
jj describe -m "better lines"
```

We can edit the previous revision (this will change @):
```shell
$ jj edit zpuvqxzw
$ jj log
○  kxnmztwm codumentary.com@gmail.com 2025-08-17 10:27:53 0ef6f602
│  better lines
@  zpuvqxzw codumentary.com@gmail.com 2025-08-17 10:21:31 test-change 21b6b955
│  test change
◆  mvuxrvnt codumentary.com@gmail.com 2025-08-16 12:36:31 main git_head() 83adab95
│  pgn_parser: make getRanges compile
```

Bookmarks don't move themselves (note that `test-change` still points to 2nd revision), you need to do it manually:
```shell
$ jj bookmark move test-change --to kxnmztwm
$ ○  kxnmztwm codumentary.com@gmail.com 2025-08-17 10:27:53 test-change 0ef6f602
│  better lines
@  zpuvqxzw codumentary.com@gmail.com 2025-08-17 10:21:31 21b6b955
│  test change
◆  mvuxrvnt codumentary.com@gmail.com 2025-08-16 12:36:31 main git_head() 83adab95
│  pgn_parser: make getRanges compile
```

```shell
$ echo haha >> test.txt
$ jj describe -m "add third haha"
$ jj edit test-change
Working copy  (@) now at: kxnmztwm 561319be test-change | (conflict) better lines
Parent commit (@-)      : zpuvqxzw 935229a3 add third haha
Added 0 files, modified 1 files, removed 0 files
Warning: There are unresolved conflicts at these paths:
test.txt    2-sided conflict
```

This caused a conflict! (and what we did was very similar to rebase)
```shell
jj show @
Commit ID: 561319bee04f6e9cde33258d2935887de4331daf
Change ID: kxnmztwmyouqyxmtwzmmtskyvyzlnrzn
Bookmarks: test-change test-change@git
Author   : alexandershov <codumentary.com@gmail.com> (2025-08-17 10:27:53)
Committer: alexandershov <codumentary.com@gmail.com> (2025-08-17 10:36:59)

    better lines

Created conflict in test.txt:
        1: <<<<<<< Conflict 1 of 1
        2: %%%%%%% Changes from base to side #1
   1    3:  haha
   2    4:  haha
   3    5: +haha
        6: +++++++ Contents of side #2
        7: first
        8: second
        9: >>>>>>> Conflict 1 of 1 ends
```

You resolve conflict by either create a new revision on top or resolving a conflict in a file:
```shell
$ echo -n "first\nsecond\nhaha" > test.txt
```

Conflict resolve now:
```shell
Commit ID: e12f9042b1499f93d1a8a7d8e24f4c94aafb95da
Change ID: kxnmztwmyouqyxmtwzmmtskyvyzlnrzn
Bookmarks: test-change test-change@git
Author   : alexandershov <codumentary.com@gmail.com> (2025-08-17 10:27:53)
Committer: alexandershov <codumentary.com@gmail.com> (2025-08-17 10:41:19)

    better lines

Modified regular file test.txt:
   1    1: hahafirst
   2    2: hahasecond
   3    3: haha
(END)
```

You can undo changes (this will undo all changes to test.txt made in current revision):
```shell
$ jj restore test.txt
$ cat test.txt
haha
haha
haha
```

We can undo that last operation:
```shell
$ jj op log
@  16c0fcaff10d aershov@Mac.home 1 minute ago, lasted 8 milliseconds
│  restore into commit e12f9042b1499f93d1a8a7d8e24f4c94aafb95da
│  args: jj restore test.txt
$ jj op undo 16c0fcaff10d
$ cat test.txt
first
second
haha%
```

That undo was pretty cool! It's like friendly `git reflog`.

You can split the last (default) revision in two:
```shell
jj split
```

During `jj split` you pick what goes in the first part of split with TUI (the rest will go to the second part)
and name both new revisions.

I've split two line change into two one-line changes:
```shell
@  mwlpqwxq codumentary.com@gmail.com 2025-08-17 12:37:23 test-change c29d19e3
│  better second line
○  kxnmztwm codumentary.com@gmail.com 2025-08-17 12:37:11 git_head() c83026d5
│  better first line
○  zpuvqxzw codumentary.com@gmail.com 2025-08-17 10:36:59 935229a3
│  add third haha
◆  mvuxrvnt codumentary.com@gmail.com 2025-08-16 12:36:31 main 83adab95
│  pgn_parser: make getRanges compile
```

We can squash several revisions in one (`@-` means "parent of @"):
```shell
jj squash --from @- --to @
```
