## Misc Python features

### dependencies `extras`
extras are a way for package maintainer to specify an extra set of dependencies. Duh.

They are specified in brackets:
```shell
pip install fastapi[all]
```

fastapi specifies `all` extra in its [pyproject.toml](https://github.com/tiangolo/fastapi/blob/2606671a0a83b1dc788ba4d2269a9d402f38e9ab/pyproject.toml#L79).
When you do `pip install fastapi[all]`, then pip install the main set of fastapi dependencies (starlette, etc.)
and then installs `all` extra set of dependencies.