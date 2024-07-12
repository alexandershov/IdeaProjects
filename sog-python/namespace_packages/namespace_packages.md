## Namespace packages

When you have directory without `__init__.py` you'll get a namespace package.

The difference from regular packages is that you can populate the same namespace package
from different places.

Consider directories [first](./first) and [second](./second). They both contain portions of namespace package `root`.

When we do
```python
import sys
sys.path.append('first')
sys.path.append('second')
```
and then

```python
import root
```

then we'll get a namespace package.

```python
>>> root
<module 'root' (namespace) from ['/Users/aershov/IdeaProjects/sog-python/namespace_packages/first/root', '/Users/aershov/IdeaProjects/sog-python/namespace_packages/second/root']>
>>> root.__path__
_NamespacePath(['/Users/aershov/IdeaProjects/sog-python/namespace_packages/first/root', '/Users/aershov/IdeaProjects/sog-python/namespace_packages/second/root'])
```

`__path__` is kinda like `sys.path` but for a single package.
Regular packages have `__path__` with a single element:
```python
>>> import torch
>>> torch.__path__
['/Users/aershov/IdeaProjects/sog-python/venv/lib/python3.12/site-packages/torch']
```

When we do
```python
import root.first
```

then python finds first/root/first.py, because `first/root` is in `__path__`.

`__path__` is dynamic attribute, when you add a path to `sys.path` that contains a new portion of namespace
package, then `__path__` will be recomputed on access.

When we do `import root`, python will search `sys.path`, if it finds portions of namespace packages
it remembers them. If search didn't find regular module/package, then namespace package is created.

So even if namespace package portion is the first in `sys.path`, it'll lose to a regular module/package
that's later in `sys.path`, because search in `sys.path` exits immediately when we find regular module/package,
but the search continues if we got a portion of namespace package.