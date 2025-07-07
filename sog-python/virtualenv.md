## virtualenv

### TODOs
* figure out pyvenv.cfg
* how pip knows that it should use virtual env?.
* wtf is happening with sys.prefix, sys.base_prefix, sys.exec_prefix, and sys.base_exec_prefix?
* why pip contains vendored-in dependencies?
* understand how does sys.prefix work
* what is PYTHONHOME in bin/activate?
 

You can create virtualenv with 
```shell
python -m venv /path/to/venv
```

E.g. you can create `.venv` dir in your project dir.
Or use `~/.virtualenvs` as a root for all virtualenvs.

`venv` will create a file `pyvenv.cfg` in this virtualenv.
This file is crucial in making virtualenv work.

`site.py` sets `sys.prefix` to a path to your virtualenv if it 
encounters `pyvenv.cfg`.

`sys.prefix` is used to populate `sys.path`.

Not directly related to virtualenvs, there are <name>.pth files. 
`site.py` adds all paths listed in site-packages/<name>.pth files to `sys.path`.

### Internals

Let's create a virtual env:

```shell
$ python3 -m venv test_venv
```

This will create a directory `test_env/` containing all virtual env machinery
```shell
$ cd test_env
$ find . -not -iwholename '*/site-packages/pip*' | sort
.
./.gitignore
./bin
./bin/Activate.ps1
./bin/activate
./bin/activate.csh
./bin/activate.fish
./bin/pip
./bin/pip3
./bin/pip3.13
./bin/python
./bin/python3
./bin/python3.13
./include
./include/python3.13
./lib
./lib/python3.13
./lib/python3.13/site-packages
./pyvenv.cfg
```

I've excluded `*site-packages/pip*` for clarity, virtual env also contains a pip installation.
This pip installation contains vendored-in pip dependencies (e.g. `requests`, `tomli`, etc):
```shell
$ ls ./lib/python3.13/site-packages/pip/_vendor
__init__.py          dependency_groups    msgpack              pygments             rich                 typing_extensions.py
__pycache__          distlib              packaging            pyproject_hooks      tomli                urllib3
cachecontrol         distro               pkg_resources        requests             tomli_w              vendor.txt
certifi              idna                 platformdirs         resolvelib           truststore
```

`bin/python` & `bin/python3` are symlinks to `./bin/python3.13` (I've created venv running 3.13):
```shell
$ file --no-dereference bin/python bin/python3
bin/python:  symbolic link to python3.13
bin/python3: symbolic link to python3.13
```

`bin/python3.13` is a symlink to a system python (kinda):
```shell
$ file --no-dereference bin/python3.13
bin/python3.13: symbolic link to /opt/homebrew/opt/python@3.13/bin/python3.13
```

Kinda, because `/opt/homebrew/opt/python@3.13/bin/python3.13` is another symlink:
```shell
$ file --no-dereference /opt/homebrew/opt/python@3.13/bin/python3.13
/opt/homebrew/opt/python@3.13/bin/python3.13: symbolic link to ../Frameworks/Python.framework/Versions/3.13/bin/python3.13
```

Luckily, it stops with `/opt/homebrew/opt/python@3.13/Frameworks/Python.framework/Versions/3.13/bin/python3.13`,
it's not a symlink:
```shell
$ file --no-dereference /opt/homebrew/opt/python@3.13/Frameworks/Python.framework/Versions/3.13/bin/python3.13
/opt/homebrew/opt/python@3.13/Frameworks/Python.framework/Versions/3.13/bin/python3.13: Mach-O 64-bit executable arm64
```

`bin/activate` is a bash/zsh script intended to be used with `source bin/activate`.

`bin/activate` prepends virtual environment's `bin/` to `$PATH`, that's why `python` finds virtual env python.


`bin/activate` also defines a bash/zsh function `deactivate` that undos all the work done by `bin/activate`.

The most interesting part of virtual environment is file `pyvenv.cfg`.

```shell
$ cat pyvenv.cfg
home = /opt/homebrew/opt/python@3.13/bin
include-system-site-packages = false
version = 3.13.5
executable = /opt/homebrew/Cellar/python@3.13/3.13.5/Frameworks/Python.framework/Versions/3.13/bin/python3.13
command = /opt/homebrew/opt/python@3.13/bin/python3.13 -m venv /Users/aershov/tmp/test_venv
```
