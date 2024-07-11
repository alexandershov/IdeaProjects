## virtualenv

You can create virtualenv with 
```shell
python -m venv /path/to/venv
```

E.g. you can create `.venv` dir in your project dir.
Or use `~/.virtualenvs` as a root for all virtualenvs.

Script creating virtualenv will create a file `pyvenv.cfg` in this virtualenv.
This file is crucial in making virtualenv work.

`site.py` sets `sys.prefix` to a path to your virtualenv if it 
encounters `pyvenv.cfg`.

`sys.prefix` is used to populate `sys.path`.

Not directly related to virtualenvs, there are <name>.pth files. 
`site.py` adds all paths listed in site-packages/<name>.pth files to `sys.path`.