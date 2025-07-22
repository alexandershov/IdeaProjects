## Mypy

Mypy is a static type checker for Python.

### Install

```shell
pip install mypy
```

### Usage

```shell
mypy example
```

By default mypy checks only annotation functions, so obvious errors
(e.g. when you try to use attributes that don't exist inside the annotated function)
will not be reported:

```python
def main():
    print(sys.whatever)
```

The above code passes typecheck, because `main` is not annotated.
You can either annotate it:

```python
def main() -> None:
    print(sys.whatever)
```

or
pass [--check-untyped-defs](https://mypy.readthedocs.io/en/stable/command_line.html#cmdoption-mypy-check-untyped-defs)
when invoking mypy:

```shell
mypy --check-untyped-defs example
```