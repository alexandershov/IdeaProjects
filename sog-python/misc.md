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


### audit events
You can print all audit events with
```python
import sys
sys.addaudithook(print)
```

You can use something else instead of `print` (log to file etc.)

Python audits many interesting events: opening files/sockets, imports of python modules etc.

### pytest
You can use `cache` fixture to share information between test _runs_.
It's persistent, essentially it just dumps/loads json into file.
It's used by pyttest to store information about last failed tests.

You can inspect the cache with
```shell
pytest --cache-show
```

If some test is hanging and you don't know which you can look at `PYTEST_CURRENT_TEST` envvar.
You need to know pid of the process running tests

This will show the environment of the process by pid:
```shell
ps eww <pid>
```

Or 
```python
import psutil
psutil.Process(48178).environ()
```

Both of these options for some reason don't work on my Mac (Sonoma 14.5)

### rich formatting in terminal

There's a `rich` library, you can print e.g. some red text:
```python
import rich
rich.print('[red]red[/red] text')
```

### terminal apps

Install:
```shell
pip install textual
```

Demo:
```shell
python -m textual
```

It's pretty cool, even mouse works, you get webapp vibe in a terminal.
