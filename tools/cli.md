# CLI Features

## zshell

### zmv

Smart file move.

Add `autoload zmv` to your ~/.zshrc

Now you can use glob groups and captured groups in zmv.
E.g., this adds `_tmp` to each python file: 
```shell
zmv '(*).py' '$1_tmp.py'
```

### Edit command line
Ctrl-x Ctrl-e will open an $EDITOR where you can edit a command line.
It works pretty badly with emacs.


### dirs
You can list directories visited in a current session:
```shell
dirs -v
```

You can navigate to a dir listed by its number. E.g., to go to dir #3:
```shell
~3
```

### Smart globs

Match only files:
```shell
ls *(.)
```

Match only directories:
```shell
ls *(/)
```

## fzf
Ctrl-T to complete current cmdline with fzf, useful when you want to select some file as an argument.

## iterm

### Search
You can use regex search. Cmd-F and select "... Regex" in a search field dropdown

### Instant replay
Cmd-Opt-B and you can time travel through the terminal history.
E.g., if you cleared the terminal window (or used top), you can time travel to the moment
before you cleared everything. Cool stuff.

### Shell Integration
Menu -> "Install Shell Integration"

Now you can:
* Highlight previous command with Cmd-Shift-Up

Right click at the beginning of each command, and you'll see each command exit code,
running time and cwd.

### Editing
Cmd-Shift-. and you can edit your command in a separate window with a reasonable
editor.

### Undo
After you accidentally close a tab, you can reopen it with Cmd-Z.
By default, you have 5 seconds to do that.
You can increase this timeout, search for "undo" in settings.
Cool stuff. 


## Variety

### git
show file content at another branch:
```shell
git show <branch-name>:path/to/file
```

### z
If you call `z` without arguments then it'll print a list of the most popular dirs, that you can
pipe into e.g. `fzf`

```shell
# tail -r is to show the best matches first
z | tail -r | fzf
```

### curl
You can check if a site supports http2:

```shell
curl -v --http2-prior-knowledge https://google.com
```
If you're getting HTTP/2 200 OK, then it supports HTTP/2.
If you're getting an error
```text
Remote peer returned unexpected data while we expected SETTINGS frame. 
Perhaps, peer does not support HTTP/2 properly.
```
then it's not your lucky day.

### python
you can run a script with `-i` and after the script exits you'll have a python console with all the script context.

```shell
python -i <script.py>
```

### less
Show line numbers:
```shell
less -N cli.md
```

Go to line e.g., 25: type "25g" when you're inside less.

Go to the previous line: type "y".

### ag 
Search only in the files matching pattern:
```shell
ag -G '.*\.md' go
```

Ignore files matching pattern:
```shell
ag --ignore '.*\.md' goto
```

### echo

Don't print newline:
```shell
echo -n "just a test"
```

Allow escape sequences:
```shell
echo -e 'just\na\ntest'
```
On Mac you don't need `-e`.

### top
Sort by memory/cpu (Mac):
```shell
top -o cpu/mem
```

Sort by memory/cpu (Linux):
```shell
top -o %CPU/RES
```

You can use other sorting criteria, use names of columns in the top output.

Show results only for a single PID (Mac):
```shell
top -pid <pid>
```

Show results only for a single PID (Linux):
```shell
top -p <pid>
```