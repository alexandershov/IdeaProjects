# CLI Features

## zshell

### zmv

Smart file move.

Add `autoload zmv` to your ~/.zshrc

now you can use glob groups and captured groups in zmv.
E.g. this adds `_tmp` to each python file: 
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

You can navigate to a dir listed by its number. E.g. to go to dir #3:
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
E.g. if you cleared the terminal window (or used top) you can time travel to the moment
before you cleared everything. Cool stuff.

### Shell Integration
Menu -> "Install Shell Integration"

Now you can:
* Highlight previous command with Cmd-Shift-Up

Right click at the beginning of each command and you'll see each command exit code,
running time and cwd.

### Editing
Cmd-Shift-. and you can edit your command in a separate window with a reasonable
editor.

### Undo
After you accidentally close a tab you can reopen it with Cmd-Z.
By default you've 5 seconds to do that.
You can increase this timeout, search for "undo" in settings.
Cool stuff. 
