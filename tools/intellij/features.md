## IntelliJ Features

<!-- TOC -->
  * [IntelliJ Features](#intellij-features)
    * [Refactoring](#refactoring)
    * [Exploring](#exploring)
    * [Editing](#editing)
    * [Running](#running)
    * [Debugging](#debugging)
    * [Navigating](#navigating)
    * [Testing](#testing)
    * [Misc](#misc)
<!-- TOC -->

Most interesting Intellij features.

### Refactoring
* You can just change name/signature and then use popup in a gutter or with Opt-Enter
  to make a refactoring out of this change.

### Exploring
* Opt-Space to show definition of current symbol in a popup.
* You can search by git commits in "Search everywhere", just paste commit sha in it.
* You can preview html files: open html file and "Open in a built-in preview" (it's in a popup with the browser icons)
  By default preview is updated on save. You can update preview as you type, change "Reload page in built-in preview" to "On change"
* If you create FastAPI project, then you can explore all endpoints via "Endpoints".
  Also HTTP client gets autocomplete for FastAPI projects
* Type Ctrl-Space when you're in a Cmd-F local search, and it'll give you some suggestions.
* Press Ctrl-Space twice (or once if autocomplete is active) 
  to search for symbols (methods/constants) inside of the classes/modules. Works pretty bad for Python.
* Expand selection works nice when you put caret at the block start (e.g. on `def` or on `if`)
* There's local history of changes that you can use to time-travel, the name is "Local history" in a menu

### Editing
You can insert table of contents in Markdown. Cmd-N and "Table of Contents"
Cmd-N in Markdown mode can also help with inserting links, images, and tables.
Opt-k to expand selection, Opt-Down to shrink selection
Cmd-Shift-U to toggle case (uppercase/lowercase)


### Running
* You can save your running configurations into file.
  Select configuration in "Edit configuration" and enable checkbox "Store as project file"
* Ctrl-Ctrl to "Run anything" (tests/scripts/etc) 
* Ctrl-G to select symbol at the caret. Pressing Ctrl-G again will select next occurrence 
  of the symbol with multiple cursors.
* Cmd-Ctrl-G will select all occurrences of the symbol at the caret with multiple cursors


### Debugging
* You can change values of variables during debugging: hover on variable and click on "Set value"
* You add inline watches for expressions: select expression and "Add inline watch"
* You can use `await` at top-level in Python console. 

### Navigating
* There are bookmarks, that you can set and jump to them. Use "Add bookmark" in a gutter.
  Cool thing that bookmark is not just for a file, but for a position in a file.
* F2 navigates to next highlighted error in a file
* Cmd-6 will show all problems in the current file
* Cmd-E open recent files. You can delete files from history with backspace
* Shift-Cmd-E will allow you to search in recent locations
* Cmd-G and Cmd-Shift-G go to the next/previous occurrence of the search

### Testing
You can drop into debugger on failed tests:
1. Enable "drop into debugger on failed test"
2. Run your tests under debugger
3. Now when tests fail you'll drop into debugger automatically. Cool stuff.


### Misc
* You can enable "Compact mode" to get more space for editing area.
