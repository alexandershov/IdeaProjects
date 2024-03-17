## Bazel
Bazel is a language-agnostic build system. 

You write build rules in Starlark.

Starlark is basically a heavily restricted subset of Python.

Bazel allows you to describe dependencies and run rules only when rule inputs change.

Bazel uses cache to speed up build process. It caches downloaded files, rule ouputs etc.
Cache is implemented as Content Addressable Storage similar to git.

Install:
```shell
brew install bazelisk
```

Bazelisk is a wrapper around bazel, that can download the required version
of bazel and run it.

Run target:
```shell
bazel run :print_leetcode_problem
```

See .bzl and .bazel files for how `:print_leetcode_problem` target is defined.