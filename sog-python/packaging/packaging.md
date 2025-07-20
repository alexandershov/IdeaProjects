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
`abi3` in wheel name means that this wheel is compatible with all python3.* releases.
Python C ABI is not backward compatible even across minor versions, but there's a stable subset of it, that is
compatible across python3.* releases.
and `abi3` means that wheel uses only this stable ABI subset.
Example of a wheel with abi3 in its name: `cryptography-45.0.5-cp311-abi3-musllinux_1_2_aarch64.whl` 

#### Content

### Sdist

### Distribution packages
Distribution package is a package on PyPI. Import package is a regular python package you can import.
Distribution package names are case-insensitive and all allowed non-alphanumeric characters (namely `_.-`)
are treated as equal and sequences of non-alphanumeric characters are collapsed into one, so this works:
```shell
pip install langchain-._OPENAI
pip freeze | rg langchain-openai
langchain-openai==0.3.28
```

### Dependencies Extras
TODO: https://setuptools.pypa.io/en/latest/userguide/dependency_management.html#optional-dependencies

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