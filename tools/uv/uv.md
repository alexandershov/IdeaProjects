## uv

uv is a fast python package & project manager.

Create project:
```shell
uv init myproject
cd myproject
```

This will create a python project (with `pyproject.toml`) in myproject/.

Add dependency to pyproject.toml:
```shell
uv add starlette
```

Run a file:
```shell
uv run main.py
```

Under the hood uv creates venv, so `uv run main.py` actually can access `starlette`.

You can create self-contained scripts based on [PEP-723](https://peps.python.org/pep-0723/):
```shell
touch script.py
uv add --script script.py pydantic
uv run script.py
```

You can add dependencies just for the single invocation:
```shell
uv run --with fastapi main.py
```

This will create venv containing extra dependency of fastapi.


You can specify python version when creating a project:
```shell
uv init myproject --python 3.14
```