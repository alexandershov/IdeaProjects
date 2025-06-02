# Bazel & Python

## Setup

There are two rulesets for python: rules_python & rules_py.
rules_py uses rules_python internally and provides its own versions of py_binary, py_library, and py_test.

rules_py is more python-ecosystem-friendly: it uses venv that plays nice with IDE, debuggers, etc.

Basic setup is this:

You write requirements.in as usual

```requirements
fastapi
```

Add call to `pip_compile` from rules_uv.
Then create empty requirements.txt (you need to have it, because requirements.txt is a dependency of a rule that
generates requirements.in) and run `bazel run //:generate_requirements_txt`.
This will resolve constraints and update `requirements.txt`

To use rules_py stuff just do `load("@aspect_rules_py//py:defs.bzl", "py_binary", "py_library", "py_test")` and
use py_binary/py_library/py_test. Actually you can use gazelle to generate BUILD files.

Add 
```starlark
# gazelle:map_kind py_library py_library @aspect_rules_py//py:defs.bzl
# gazelle:map_kind py_binary py_binary @aspect_rules_py//py:defs.bzl
# gazelle:map_kind py_test py_test @aspect_rules_py//py:defs.bzl
```
to a top-most BUILD.bazel file. Now gazelle is rules_py-friendly.

To add gazelle you need add rules `modules_mapping`, `gazelle_python_manifest`, `gazelle`, empty file `gazelle_python.yaml` and
run `bazel run //:gazelle_python_manifest.update` to create gazelle manifest.
And then you can regenerate BUILD files with bazel run //:gazelle

## rules_python

### wheel generation