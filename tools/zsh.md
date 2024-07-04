## zsh features

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
