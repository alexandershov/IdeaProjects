## tmux

tmux is a modern alternative to `screen`.

Install:
```shell
brew install tmux
```

`ctrl-b %` splits a pane into left and right.
`ctrl-b "` splits a pane into top and bottom.
`ctrl-b <arrow_key>` navigates panes.
`ctrl-b d` detaches from a session.

`tmux ls` lists available sessions.

`tmux attach -t <n>` attaches to session `n`.
`tmux rename-session -t <n> <new-name>` renames session `n` to some meaningful name.

The default tmux prefix is `ctrl-b` which conflicts with "go to previous char" in emacs-like bindings.

To set Alt-m as a tmux prefix, add this to ~/.tmux.conf:

```text
unbind C-b
set -g prefix M-m
bind -n M-m send-prefix
```