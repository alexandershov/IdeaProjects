## IntelliJ New Features

Most interesting Intellij new features since 2020.1

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


### Running
* You can save your running configurations into file.
  Select configuration in "Edit configuration" and enable checkbox "Store as project file"


### Debugging
* You can change values of variables during debugging: hover on variable and click on "Set value"
* You add inline watches for expressions: select expression and "Add inline watch"


### Navigating
* There are bookmarks, that you can set and jump to them. Use "Add bookmark" in a gutter.
  Cool thing that bookmark is not just for a file, but for a position in a file.


### Testing
You can drop into debugger on failed tests:
1. Enable "drop into debugger on failed test"
2. Run your tests under debugger
3. Now when tests fail you'll drop into debugger automatically. Cool stuff.

