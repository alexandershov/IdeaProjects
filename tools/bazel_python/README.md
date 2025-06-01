# Bazel & Python

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