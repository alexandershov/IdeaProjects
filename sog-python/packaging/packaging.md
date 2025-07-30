## Python packaging

### Prerequisites

Let's download wheel for uvloop:

```shell
curl -OL https://files.pythonhosted.org/packages/3f/8d/2cbef610ca21539f0f36e2b34da49302029e7c9f09acef0b1c3b5839412b/uvloop-0.21.0
-cp313-cp313-macosx_10_13_universal2.whl
```

Let's download sdist for uvloop

```shell
curl -OL https://files.pythonhosted.org/packages/af/c0/854216d09d33c543f12a44b393c402e89a920b1a0a7dc634c42de91b9cf6/uvloop-0.21.0.tar.gz
```

Here are our files:

```shell
➜  packaging_playground ls | cat
uvloop-0.21.0-cp313-cp313-macosx_10_13_universal2.whl
uvloop-0.21.0.tar.gz
```

### Pyproject.toml
In pyproject.toml you define, ahem, your project properties.
See [pyproject.toml](./pyproject.toml) for an example and walkthrough.
You can build your package with (you'd need to do `pip install build` first):

```shell
python -m build .
```

This created source distribution (aka sdist) & binary distribution (aka wheel):
```shell
$ ls dist | cat
mypackage-0.0.1-py3-none-any.whl
mypackage-0.0.1.tar.gz
```

`build` creates a new virtualenv in which it performs the build, from the logs of `python -m build .`:
```shell
* Creating isolated environment: venv+pip...
* Installing packages in isolated environment:
  - setuptools
```

### Wheel

#### Name
Wheel name format is `{distribution-name}-{version}-{python-tag}-{abi-tag}-{platform-tag}.whl` (I've ignored `build-tag` stuff, it's rarely used)
E.g. wheel name `uvloop-0.21.0-cp313-cp313-musllinux_1_2_x86_64.whl` means:
* it's a wheel for a distribution package `uvloop`
* version of distribution package is `0.21.0`
* compatible with cpython 3.13 (`cp` stands `cpython`)
* ABI-compatible with cpython 3.13
* compatible with [musl](https://en.wikipedia.org/wiki/Musl) linux and x86_64 cpu architecture

Here's another example `uvicorn-0.35.0-py3-none-any.whl`, meaning that this wheel is compatible with:
* any python3 (this includes cpython, pypy, etc. `py` stands for "generic python")
* no restriction on python ABI (`none`)
* no restriction on architecture (`any`)

Essentially all pure python packages will end with `py3-none-any`.
There's special `manylinux{x}` platform tag which means compatibility with a range of linuxes having some suitable glibc version.

`abi3` in wheel name means that this wheel is compatible with all python3.* releases.
Python C ABI is not backward compatible even across minor versions, but there's a stable subset of it, that is
compatible across python3.* releases.
and `abi3` means that wheel uses only this stable ABI subset.
Example of a wheel with abi3 in its name: `cryptography-45.0.5-cp311-abi3-musllinux_1_2_aarch64.whl`

Question: is this cryptography wheel compatible with python3.11+?
[PEP-425](https://peps.python.org/pep-0425/) is kinda vague in this regard, but reality is that, yes,
python tag `cp311` means that wheel will be considered compatible with 3.11, 3.12, 3.13, ...

[Reference implementation](https://packaging.pypa.io/en/stable/tags.html#packaging.tags.sys_tags) of supported tags for a current platform is in the `packaging.tags`:
```python
>>> import sys
>>> import packaging.tags

>>> print(sys.version)
3.13.5 (main, Jun 11 2025, 15:36:57) [Clang 17.0.0 (clang-1700.0.13.3)]

>>> for tag in packaging.tags.sys_tags(): print(tag)
<REDACTED>
py312-none-any
py311-none-any
py310-none-any
py39-none-any
py38-none-any
py37-none-any
py36-none-any
py35-none-any
py34-none-any
py33-none-any
py32-none-any
py31-none-any
py30-none-any
```

See also quite illuminating [discussion](https://discuss.python.org/t/python-tags-specific-version-of-interpreter-or-minimum-version/7831/27) about this.

#### Content
platlib vs purelib: some systems make distinction where to install platform dependent files (e.g. `.so`)
and platform independent (e.g. `.py`), that's it.
Inside of the wheel there's a file called WHEEL, for pure python packages it'll have
`Root-Is-Purelib: true`

Here's an example of wheel content:
```shell
unzip -l dist/mypackage-0.0.1-py3-none-any.whl
Archive:  dist/mypackage-0.0.1-py3-none-any.whl
  Length      Date    Time    Name
---------  ---------- -----   ----
       21  07-19-2025 15:40   mypackage/__init__.py
       70  07-19-2025 15:45   mypackage/cli.py
        0  07-19-2025 15:30   mypackage/lib.py
      135  07-20-2025 12:17   mypackage-0.0.1.dist-info/METADATA
       91  07-20-2025 12:17   mypackage-0.0.1.dist-info/WHEEL
       53  07-20-2025 12:17   mypackage-0.0.1.dist-info/entry_points.txt
       10  07-20-2025 12:17   mypackage-0.0.1.dist-info/top_level.txt
      619  07-20-2025 12:17   mypackage-0.0.1.dist-info/RECORD
```

`mypackage-0.0.1.dist-info` contains wheel metadata:
WHEEL contains wheel version, generator (which build backend created a wheel), and tags.
```shell
unzip -p dist/mypackage-0.0.1-py3-none-any.whl mypackage-0.0.1.dist-info/WHEEL
Wheel-Version: 1.0
Generator: setuptools (80.9.0)
Root-Is-Purelib: true
Tag: py3-none-any
```

More wheel info is in the METADATA:
```shell
unzip -p httpx-0.28.1-py3-none-any.whl httpx-0.28.1.dist-info/METADATA
Metadata-Version: 2.3
Name: httpx
Version: 0.28.1
<REDACTED>
Requires-Python: >=3.8
Requires-Dist: anyio
Requires-Dist: certifi
Requires-Dist: httpcore==1.*
Requires-Dist: idna
Provides-Extra: brotli
Requires-Dist: brotli; (platform_python_implementation == 'CPython') and extra == 'brotli'
Requires-Dist: brotlicffi; (platform_python_implementation != 'CPython') and extra == 'brotli'
Provides-Extra: cli
Requires-Dist: click==8.*; extra == 'cli'
Requires-Dist: pygments==2.*; extra == 'cli'
Requires-Dist: rich<14,>=10; extra == 'cli'
Provides-Extra: http2
Requires-Dist: h2<5,>=3; extra == 'http2'
Provides-Extra: socks
Requires-Dist: socksio==1.*; extra == 'socks'
Provides-Extra: zstd
Requires-Dist: zstandard>=0.18.0; extra == 'zstd'
```

METADATA contains dependencies (Requires-Dist), extras (Provides-Extra), required python version (Requires-Python) and other stuff.
extras are used as platform specifiers in Requires-Dist.

RECORD contains all wheel files with their hashes.

#### Installation
Wheel installation is essentially 
* unpacking into correct directory (purelib/platlib) and
* rewriting `#!python` with the current python interpreter (could be in venv)
* compiling .pyc files

### Sdist
Sdist is a tar.gz file containing package source:
```shell
tar -tzf dist/mypackage-0.0.1.tar.gz
mypackage-0.0.1/
mypackage-0.0.1/PKG-INFO
mypackage-0.0.1/pyproject.toml
mypackage-0.0.1/setup.cfg
mypackage-0.0.1/src/
mypackage-0.0.1/src/mypackage/
mypackage-0.0.1/src/mypackage/__init__.py
mypackage-0.0.1/src/mypackage/cli.py
mypackage-0.0.1/src/mypackage/lib.py
mypackage-0.0.1/src/mypackage.egg-info/
mypackage-0.0.1/src/mypackage.egg-info/PKG-INFO
mypackage-0.0.1/src/mypackage.egg-info/SOURCES.txt
mypackage-0.0.1/src/mypackage.egg-info/dependency_links.txt
mypackage-0.0.1/src/mypackage.egg-info/entry_points.txt
mypackage-0.0.1/src/mypackage.egg-info/requires.txt
mypackage-0.0.1/src/mypackage.egg-info/top_level.txt
```
Main parts of this archive are:
* top-level folder in the archive is the `{name}-{version}`
* then pyproject.toml
* and source code (in unspecified format)

The format in which source code is stored is not specified, but general idea that it should be enough
stuff to build a wheel from it.

Also sdist contains PKG-INFO which has the same format & data as METADATA in a wheel.

### Installation
When you install python project aside from the code itself installation tool will also create a 
`{name}-{version}.dist-info` directory in site-packages/ containing metainformation about the installation:
```shell
$ ls ~/.virtualenvs/packaging_playground/lib/python3.13/site-packages/httpx-0.28.1.dist-info | cat
INSTALLER
METADATA
RECORD
WHEEL
entry_points.txt
licenses
```

INSTALLER contains the name of the tool that installed the package:
```shell
$ cat INSTALLER
pip
```

METADATA is the same as PKG-INFO in sdist or METADATA in a wheel.

RECORD is a list of installed files:
```shell
cat RECORD
../../../bin/httpx,sha256=BoI7FDnFmx4J-UdjO0fC1HbpVOm0hwudwB3mGG9X00c,251
httpx-0.28.1.dist-info/INSTALLER,sha256=zuuue4knoyJ-UwPPXg8fezS7VCrXJQrAP7zeNuwvFQg,4
httpx-0.28.1.dist-info/METADATA,sha256=_rubD48-gNV8gZnDBPNcQzboWB0dGNeYPJJ2a4J5OyU,7052
<REDACTED>
```

RECORD can be used by a package manager to uninstall a package. Algorithm for removal is:
1. Remove all files from RECORD
2. Remove all .pyc files for each .py file in RECORD
3. Remove all empty directories


### Distribution packages
Distribution package is a package on PyPI. Import package is a regular python package you can import.
Distribution package names are case-insensitive and all allowed non-alphanumeric characters (namely `_.-`)
are treated as equal and sequences of non-alphanumeric characters are collapsed into one, so this works:
```shell
pip install langchain-._OPENAI
pip freeze | rg langchain-openai
langchain-openai==0.3.28
```

### Entry points
Entry points is a way to add additional metadata to your projects.
E.g. you can add
```toml
[project.scripts]
httpx = "httpx:main"
```

in your `pyproject.toml` and wheel will contain 
```text
[console_scripts]
httpx = httpx:main
```

`httpx` will be a file name and `httpx:main` is a path to python function `main` in a module `httpx`.

console_script is just a well-known entrypoint with a support from a python tooling, but you can define
non-console_scripts entry points. See `[project.entry-points]` section in [pyproject.toml](./pyproject.toml) 
for how you can define entry point.
You can query entrypoints with `importlib.metadata`:

```pycon
>>> from importlib.metadata import entry_points
>>> eps = entry_points()
>>> list(eps)[1]
EntryPoint(name='adder', value='mypackage.lib:add', group='my.entry.point.group')
>>> list(eps)[1].load()
<function add at 0x1055547c0>
>>> list(eps)[1].load()(3, 2)
5
>>>
```

`EntryPoint.load()` resolves entrypoint value to a python object.
Entrypoints are used by e.g. pytest for plugins: you write a package that provides entrypoint in a
group `pytest11` and pytest will get it with the `importlib.metadata`.

### Dependencies specification
The simplest way to specify dependency is just name it: e.g. for `httpx` just specify `httpx`

Specific version:
```text
httpx==0.28.1
```

Version range:
```text
httpx>=0.28.1,<1.0.0
```

Another way to define ranges for compatible releases:
```text
httpx ~= 0.28
```

This is the same as:
```text
httpx >= 0.28, == 0.*
```


Platform restrictions (most useful are python version and OS, `and|or` are supported):
```text
httpx==0.28.1; python_version>=3.9 and platform_system == 'linux or platform_system = 'macos' 
```

Direct url:
```text
httpx @ https://files.pythonhosted.org/packages/2a/39/e50c7c3a983047577ee07d2a9e53faf5a69493943ec3f6a384bdc792deb2/httpx-0.28.1-py3-none-any.whl
```

Local path:
```text
httpx @ file:///path/to/httpx.whl
```

Dependencies extras. Packages can specify dependencies extra to add additional dependencies, e.g.
`httpx` defines an [extra set](https://github.com/encode/httpx/blob/4fb9528c2f5ac000441c3634d297e77da23067cd/pyproject.toml#L48-L50) of dependencies for http2.

You can request this extra set with:
```text
httpx[http2]
```

You can separate several extras with the comma:
```text
httpx[cli,http]
```

Dependencies from the extras sets will be unioned.


### Rest
#### Versioning
You can determine version of any installed package programmatically 
(no need to guess with `{package_name}.__version__` which is not always present):
```python
import importlib.metadata
importlib.metadata.version("httpx")
'0.28.1'
```

TODO: 
* Install editable https://setuptools.pypa.io/en/latest/userguide/development_mode.html
* Requirements format (extras, versions, file/http/etc)
* pip install --no-index --find-links
* entrypoints
* pipx
* python -m build