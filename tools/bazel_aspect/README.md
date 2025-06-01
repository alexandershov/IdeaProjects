# Bazel & Aspect

## Install
```shell
brew install aspect-build/aspect/aspect
```

This install aspect CLI that wraps bazel & adds useful commands (e.g. `bazel init` to create a project) 

## Adding dependency
Update pyproject.toml and run

```shell
./tools/repin
```

This will update all requirement lock files.
It will also run `aspect configure` that autogenerates BUILD files.

Run binary with 
```
bazel run //app:app_bin
```

Each py_binary from rules_py includes venv
```shell
$ bazel query --output=label_kind app:all
py_binary rule //app:app_bin
determine_main rule //app:app_bin.find_main
py_venv_binary rule //app:app_bin.venv
```

You can build this venv with
```shell
bazel run //app:app_bin.venv
```

and point your IDE to it, so you'll get autocomplete etc.

After you add a test (you can use pytest) you need to run
```shell
aspect configure
```

to regenerate BUILD files and run the test

```shell
bazel test //app:test_add
```

Aspect CLI also adds formatters and linters:
```shell
bazel run format
bazel lint app/...
```