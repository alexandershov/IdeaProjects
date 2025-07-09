## virtualenv

### TODOs
* how does ensurepip work?
* how pip knows that it should use virtual env?.
* what is PYTHONHOME in bin/activate?
 

### Create venv

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

### Pip

I've excluded `*site-packages/pip*` for clarity, virtual env also contains a pip installation.
This pip installation contains vendored-in pip dependencies (e.g. `requests`, `tomli`, etc):
```shell
$ ls ./lib/python3.13/site-packages/pip/_vendor
__init__.py          dependency_groups    msgpack              pygments             rich                 typing_extensions.py
__pycache__          distlib              packaging            pyproject_hooks      tomli                urllib3
cachecontrol         distro               pkg_resources        requests             tomli_w              vendor.txt
certifi              idna                 platformdirs         resolvelib           truststore
```

This vendoring is actually how `pip` operates: it vendors its dependencies. 
Reasons are [described](https://github.com/pypa/pip/blob/main/src/pip/_vendor/README.rst) in a pip repo.
One of the reasons: `pip` requires a fairly recent version of `requests`, this means that if you use `pip`
then all of your dependencies should be compatible with the recent version of `requests` which is nonsense. 
In general package manager should be independent of your project and your project dependencies. Vendoring is the
`pip` way of doing this.


### Python executables
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

### bin/activate
`bin/activate` is a bash/zsh script intended to be used with `source bin/activate`.

`bin/activate` prepends virtual environment's `bin/` to `$PATH`, that's why `python` finds virtual env python.

`bin/activate` also defines a bash/zsh function `deactivate` that undos all the work done by `bin/activate`.

There's no need to `bin/activate`, it just modifies `$PATH`, nothing stops you from executing venv's python directly.

### pyvenv.cfg
The most interesting part of virtual environment is file `pyvenv.cfg`.

```shell
$ cat pyvenv.cfg
home = /opt/homebrew/opt/python@3.13/bin
include-system-site-packages = false
version = 3.13.5
executable = /opt/homebrew/Cellar/python@3.13/3.13.5/Frameworks/Python.framework/Versions/3.13/bin/python3.13
command = /opt/homebrew/opt/python@3.13/bin/python3.13 -m venv /Users/aershov/tmp/test_venv
```

If a parent directory of directory containing sys.executable contains pyvenv.cfg then python sets `sys.prefix` equal to a path to virtual env.
(and `sys.exec_prefix` but I'll ignore `sys.exec_prefix` for simplicity, it's not that important).

Inside virtual env `sys.prefix` points to a virtual env:
```shell
$ python3 -c 'import sys; print(sys.prefix)'
/Users/aershov/tmp/test_venv
```

Outside virtual env `sys.prefix` points to a system-wide installation:
```shell
 python3 -c 'import sys; print(sys.prefix)'
/opt/homebrew/opt/python@3.13/Frameworks/Python.framework/Versions/3.13
```

When using virtual env, that's exactly the case, cause we got `pyvenv.cfg` in a right place:

```shell
find . -iwholename '*bin/python3' -or -iname 'pyvenv.cfg'
./bin/python3
./pyvenv.cfg
```

Note that pyvenv.cfg is in the parent of `bin/`.

Now `site.py` does the final modification of `sys.path` to point it to venv `site-packages/`.

During each (unless you specify `-S`) python startup `site.py` is executed.
`site.py` will update `sys.path` and it'll add `{sys.prefix}/lib/python{version}/site-packages` to a 
sys.path. Proof:
```shell
python3 -c 'import sys; print(sys.path[-1])'
/Users/aershov/tmp/test_venv/lib/python3.13/site-packages
```

If virtual env is not used, then `sys.prefix` will not be related to venv and global site-packages will be added to a `sys.path`
`sys.base_prefix` is a prefix ignoring virtual env, so `sys.base_prefix != sys.prefix` if we're running under virtual env.

### .pth files
If `site-packages/` contains any `*.pth` files, then `site.py` will add paths listed in these files to
`sys.path`.

```shell
$ python3 -c 'import sys; print(sys.path[-1])'
/Users/aershov/tmp/test_venv/lib/python3.13/site-packages
```

Let's add some .pth file:
```shell
$ echo pip >> /Users/aershov/tmp/test_venv/lib/python3.13/site-packages/paths.pth
```

Now `sys.path` will contain this path:
```shell
$ python3 -c 'import sys; print(sys.path[-1])'
/Users/aershov/tmp/test_venv/lib/python3.13/site-packages/pip
```

Note, that we've added a relative path to `.pth` file and `sys.path` resolved it to an absolute path.
It essentially did `os.path.join("path/to/site-packages/", path_in_pth_file)`  