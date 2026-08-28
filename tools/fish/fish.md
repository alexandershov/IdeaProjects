# Fish

## What is it?
Fish is an interactive shell with good default and without legacy of bash.
Looks pretty cool.

## Install
```shell
brew install fish
```

## Usage

Start it with
```shell
fish
```

## Features
* Good defaults - no need for oh-my-zsh-like plugins, all of it works out of the bo
* Syntax highlighting - fish highlights files, redhighlights unknown commands
* exit code of the previous command is immediately visible in the prompt: 
```shell
lsdkf
fish: Unknown command: lsdkf
aershov@Mac ~/tmp [127]>
```
* context-aware autocomplete: completes commands, file names, options (`--*`)
* nicer shell history - essentially fzf-like out of the box
* Sane scripting language. Since it's sane it's not compatible with `bash`
* abbreviations: `abbr rrr rg test` and test type `rrr`, press space and you'll get replacement

### Scripting
```shell
# set is the way to assign variables in fish
set x 9
if test "$x" = 9
  echo 'nein'
end
```

## Universal variables

Universal variables are persistent and they're immediately shared between fish instances
```shell
# start 2 fish shells
# in the first do
set -U HAHA boom
# the second one use universal variable without reload 
echo $HAHA
```