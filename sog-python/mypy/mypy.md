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

### Stubs
If you have a module that dynamically generates its attributes (e.g. changing `globals()`), then
mypy won't see this dynamically generated attributes.
But you can create a stub file (`X.pyi`) that will have interfaces of functions/classes/etc in a `X.py`
and mypy can use that. See [lib.pyi](./example/lib.pyi) for an example: it adds a type hint for a 
`fn` that is dynamically injected into `globals()` in `lib.py`.