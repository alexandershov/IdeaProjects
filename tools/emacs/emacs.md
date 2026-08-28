# Emacs

## What is it?
You know what it is.


## Recent new features
LSP+tree-sitter


python-ts-mode is a tree-sitter based python mode (alternative to an old mode - based on regexes/etc)
You need to install python grammar to python-ts-mode:
```text
(setq treesit-language-source-alist
      '((python "https://github.com/tree-sitter/tree-sitter-python")))
```

And then `M-x treesit-install-language-grammar` and type `python`.

eglot is a LSP client.
Add it to your .emacs.
```text
(use-package eglot
  :hook (python-ts-mode . eglot-ensure))
```

You need to have some python lsp implementation, e.g. pyright:
```shell
npm install -g pyright
```

You can make `python-ts-mode` default:
```shell
(add-to-list 'major-mode-remap-alist
             '(python-mode . python-ts-mode))
```

eglot will use LSP automatically if some LSP server is available.
For some reason it doesn't always work: e.g. it doesn't like directories with a lot of files.

To setup nicer than default autocompletion use corfu:
```text
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-prefix 1)
  (corfu-auto-delay 0.1)
  :init
  (global-corfu-mode 1))

(use-package corfu-terminal
  :ensure t
  :after corfu
  :config
  (corfu-terminal-mode 1))
```

Now popups will appear when you write code. Almost like an IDE.

With `M-x completion-preview-mode` you can have faint completions in your buffer to preview how it'll look like.