# Bazel & Python

## Setup

There are two rulesets for python: rules_python & rules_py.
rules_py uses rules_python internally and provides its own versions of py_binary, py_library, and py_test.

rules_py is more python-ecosystem-friendly: it uses venv that plays nice with IDE, debuggers, etc.

Basic setup is this:

You write requirements.in as usual

```requirements
fastapi
```

Add call to `pip_compile` from rules_uv.
Then create empty requirements.txt (you need to have it, because requirements.txt is a dependency of a rule that
generates requirements.in) and run `bazel run //:generate_requirements_txt`.
This will resolve constraints and update `requirements.txt`

To use rules_py stuff just do `load("@aspect_rules_py//py:defs.bzl", "py_binary", "py_library", "py_test")` and
use py_binary/py_library/py_test. Actually you can use gazelle to generate BUILD files.

Add 
```starlark
# gazelle:map_kind py_library py_library @aspect_rules_py//py:defs.bzl
# gazelle:map_kind py_binary py_binary @aspect_rules_py//py:defs.bzl
# gazelle:map_kind py_test py_test @aspect_rules_py//py:defs.bzl
```
to a top-most BUILD.bazel file. Now gazelle is rules_py-friendly.

To add gazelle you need add rules `modules_mapping`, `gazelle_python_manifest`, `gazelle`, empty file `gazelle_python.yaml` and
run `bazel run //:gazelle_python_manifest.update` to create gazelle manifest.
And then you can regenerate BUILD files with bazel run //:gazelle

## rules_python
The best way to explore rules_python internals is to check out rules_python source, use it with local_path_override and study/debug source code (e.g. print in starlark files)

### wheel generation
"Calls" (they are not actually calls, it's tagging) to `pip.parse` are handled [here](https://github.com/bazel-contrib/rules_python/blob/9429ae6446935059e79047654d3fe53d60aadc31/python/private/pypi/extension.bzl#L437)

We'll get to [_create_whl_repos](https://github.com/bazel-contrib/rules_python/blob/9429ae6446935059e79047654d3fe53d60aadc31/python/private/pypi/extension.bzl#L501)

Then we'll create whl_library & hub repositories [here](https://github.com/bazel-contrib/rules_python/blob/9429ae6446935059e79047654d3fe53d60aadc31/python/private/pypi/extension.bzl#L631-L634).

whl_library is implemented [here](https://github.com/bazel-contrib/rules_python/blob/9429ae6446935059e79047654d3fe53d60aadc31/python/private/pypi/whl_library.bzl#L590).

It's a repo rule.

hub_repository is also a repo rule and it's implemented [here](https://github.com/bazel-contrib/rules_python/blob/9429ae6446935059e79047654d3fe53d60aadc31/python/private/pypi/hub_repository.bzl#L71).

At the end of the day whl_library will generate a repo with BUILD.bazel [here](https://github.com/bazel-contrib/rules_python/blob/9429ae6446935059e79047654d3fe53d60aadc31/python/private/pypi/whl_library.bzl#L474).
This BUILD.bazel is materialized in `$(bazel info output_base)/external/{whl_repo_name}/BUILD.bazel`.

Here's an example of how this BUILD.bazel looks like:
```starlark
load("@rules_python//python/private/pypi:whl_library_targets.bzl", "whl_library_targets")

package(default_visibility = ["//visibility:public"])

whl_library_targets(
    data_exclude = [],
    dep_template = "@pypi//{name}:{target}",
    dependencies = ["anyio"],
    dependencies_by_platform = {},
    entry_points = {},
    group_deps = [],
    group_name = "",
    name = "starlette-0.46.2-py3-none-any.whl",
    tags = [
        "pypi_name=starlette",
        "pypi_version=0.46.2",
    ],
)
```

whl_library_targets expands (`bazel query --output=build @@rules_python++pip+pypi_313_starlette//...`) into:
```starlark
# /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi_313_starlette/BUILD.bazel:5:20
filegroup(
  name = "data",
  visibility = ["//visibility:public"],
  generator_name = "starlette-0.46.2-py3-none-any.whl",
  generator_function = "whl_library_targets",
  generator_location = "/private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi_313_starlette/BUILD.bazel:5:20",
  srcs = [],
)
# Rule data instantiated at (most recent call last):
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi_313_starlette/BUILD.bazel:5:20            in <toplevel>
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python+/python/private/pypi/whl_library_targets.bzl:185:25 in whl_library_targets

# /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi_313_starlette/BUILD.bazel:5:20
filegroup(
  name = "dist_info",
  visibility = ["//visibility:public"],
  generator_name = "starlette-0.46.2-py3-none-any.whl",
  generator_function = "whl_library_targets",
  generator_location = "/private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi_313_starlette/BUILD.bazel:5:20",
  srcs = ["@@rules_python++pip+pypi_313_starlette//:site-packages/starlette-0.46.2.dist-info/INSTALLER", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette-0.46.2.dist-info/METADATA", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette-0.46.2.dist-info/RECORD", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette-0.46.2.dist-info/WHEEL", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette-0.46.2.dist-info/licenses/LICENSE.md"],
)
# Rule dist_info instantiated at (most recent call last):
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi_313_starlette/BUILD.bazel:5:20            in <toplevel>
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python+/python/private/pypi/whl_library_targets.bzl:185:25 in whl_library_targets

# /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi_313_starlette/BUILD.bazel:5:20
py_library(
  name = "pkg",
  visibility = ["//visibility:public"],
  tags = ["pypi_name=starlette", "pypi_version=0.46.2"],
  generator_name = "starlette-0.46.2-py3-none-any.whl",
  generator_function = "whl_library_targets",
  generator_location = "/private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi_313_starlette/BUILD.bazel:5:20",
  data = ["@@rules_python++pip+pypi_313_starlette//:site-packages/starlette-0.46.2.dist-info/INSTALLER", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette-0.46.2.dist-info/METADATA", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette-0.46.2.dist-info/WHEEL", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette-0.46.2.dist-info/licenses/LICENSE.md", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/py.typed"],
  deps = ["@pypi//anyio:pkg"],
  pyi_srcs = [],
  srcs = ["@@rules_python++pip+pypi_313_starlette//:site-packages/__init__.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/__init__.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/_exception_handler.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/_utils.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/applications.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/authentication.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/background.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/concurrency.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/config.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/convertors.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/datastructures.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/endpoints.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/exceptions.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/formparsers.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/middleware/__init__.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/middleware/authentication.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/middleware/base.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/middleware/cors.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/middleware/errors.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/middleware/exceptions.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/middleware/gzip.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/middleware/httpsredirect.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/middleware/sessions.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/middleware/trustedhost.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/middleware/wsgi.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/requests.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/responses.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/routing.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/schemas.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/staticfiles.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/status.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/templating.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/testclient.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/types.py", "@@rules_python++pip+pypi_313_starlette//:site-packages/starlette/websockets.py"],
  imports = ["site-packages"],
  experimental_venvs_site_packages = "@rules_python//python/config_settings:venvs_site_packages",
)
# Rule pkg instantiated at (most recent call last):
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi_313_starlette/BUILD.bazel:5:20            in <toplevel>
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python+/python/private/pypi/whl_library_targets.bzl:322:25 in whl_library_targets
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python+/python/py_library.bzl:42:21                        in py_library
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python+/python/private/py_library_macro.bzl:21:20          in py_library
# Rule py_library defined at (most recent call last):
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python+/python/private/py_library_rule.bzl:18:52 in <toplevel>
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python+/python/private/rule_builders.bzl:504:44  in lambda
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python+/python/private/rule_builders.bzl:550:16  in _Rule_build

# /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi_313_starlette/BUILD.bazel:5:20
filegroup(
  name = "whl",
  visibility = ["//visibility:public"],
  generator_name = "starlette-0.46.2-py3-none-any.whl",
  generator_function = "whl_library_targets",
  generator_location = "/private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi_313_starlette/BUILD.bazel:5:20",
  srcs = ["@@rules_python++pip+pypi_313_starlette//:starlette-0.46.2-py3-none-any.whl"],
  data = ["@pypi//anyio:whl"],
)
# Rule whl instantiated at (most recent call last):
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi_313_starlette/BUILD.bazel:5:20            in <toplevel>
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python+/python/private/pypi/whl_library_targets.bzl:287:25 in whl_library_targets

```

Two most interesting targets are `:pkg` and `:whl`. `:pkg` is a py_library with the package itself.
package has its own `site-packages/` that contains source files. 
`:whl` is a wheel file with all dependencies (note that starlette depends on anyio in `data = `).

To build wheels (if only sdist is available) it'll [call pip](https://github.com/bazel-contrib/rules_python/blob/9429ae6446935059e79047654d3fe53d60aadc31/python/private/pypi/whl_installer/wheel_installer.py#L146-L152). 

wheel_installer executes code with the [host_toolchain](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/toolchains_repo.bzl#L290)
interpreter. And this interpreter contains only pip as a third-party dependency in site-packages.

This host interpreter symlinks `python` binary to a binary in e.g. rules_python++python+python_3_13_aarch64-apple-darwin repository.

whl repos are available via name e.g. `@@rules_python++pip+pypi_313_starlette`.
pypi_313_starlette is a value of `name` argument to `whl_library`.

Good way to explore all available repos (after you've materialized them) is to look at the dir names in 
`$(bazel info output_base)/external`.

hub_repository is available via name `@{hub_name}` or `@@rules_python++pip+{hub_name}`

E.g. `starlette` package in `@pypi` has this BUILD.bazel (`less $(bazel info output_base)/external/rules_python++pip+pypi/starlette/BUILD.bazel`):
```starlark
load("@rules_python//python/private/pypi:pkg_aliases.bzl", "pkg_aliases")

package(default_visibility = ["//visibility:public"])

pkg_aliases(
    name = "starlette",
    actual = {
        "//_config:is_cp313": "pypi_313_starlette",
    },
)
```

It expands (`bazel query --output=build @pypi//starlette/...`) into 
```starlark
# /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi/starlette/BUILD.bazel:5:12
alias(
  name = "_no_matching_repository",
  visibility = ["//visibility:private"],
  tags = ["manual"],
  generator_name = "starlette",
  generator_function = "pkg_aliases",
  generator_location = "starlette/BUILD.bazel:5:12",
  actual = select({"@rules_python//python/config_settings:is_not_matching_current_config": "@rules_python//python:none"}),
)
# Rule _no_matching_repository instantiated at (most recent call last):
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi/starlette/BUILD.bazel:5:12        in <toplevel>
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python+/python/private/pypi/pkg_aliases.bzl:161:14 in pkg_aliases

# /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi/starlette/BUILD.bazel:5:12
alias(
  name = "data",
  generator_name = "starlette",
  generator_function = "pkg_aliases",
  generator_location = "starlette/BUILD.bazel:5:12",
  actual = select({"@pypi//_config:is_cp313": "@@rules_python++pip+pypi_313_starlette//:data", "//conditions:default": "@pypi//starlette:_no_matching_repository"}),
)
# Rule data instantiated at (most recent call last):
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi/starlette/BUILD.bazel:5:12        in <toplevel>
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python+/python/private/pypi/pkg_aliases.bzl:204:14 in pkg_aliases

# /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi/starlette/BUILD.bazel:5:12
alias(
  name = "dist_info",
  generator_name = "starlette",
  generator_function = "pkg_aliases",
  generator_location = "starlette/BUILD.bazel:5:12",
  actual = select({"@pypi//_config:is_cp313": "@@rules_python++pip+pypi_313_starlette//:dist_info", "//conditions:default": "@pypi//starlette:_no_matching_repository"}),
)
# Rule dist_info instantiated at (most recent call last):
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi/starlette/BUILD.bazel:5:12        in <toplevel>
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python+/python/private/pypi/pkg_aliases.bzl:204:14 in pkg_aliases

# /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi/starlette/BUILD.bazel:5:12
alias(
  name = "pkg",
  generator_name = "starlette",
  generator_function = "pkg_aliases",
  generator_location = "starlette/BUILD.bazel:5:12",
  actual = select({"@pypi//_config:is_cp313": "@@rules_python++pip+pypi_313_starlette//:pkg", "//conditions:default": "@pypi//starlette:_no_matching_repository"}),
)
# Rule pkg instantiated at (most recent call last):
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi/starlette/BUILD.bazel:5:12        in <toplevel>
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python+/python/private/pypi/pkg_aliases.bzl:204:14 in pkg_aliases

# /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi/starlette/BUILD.bazel:5:12
alias(
  name = "starlette",
  generator_name = "starlette",
  generator_function = "pkg_aliases",
  generator_location = "starlette/BUILD.bazel:5:12",
  actual = "@pypi//starlette:pkg",
)
# Rule starlette instantiated at (most recent call last):
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi/starlette/BUILD.bazel:5:12        in <toplevel>
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python+/python/private/pypi/pkg_aliases.bzl:144:10 in pkg_aliases

# /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi/starlette/BUILD.bazel:5:12
alias(
  name = "whl",
  generator_name = "starlette",
  generator_function = "pkg_aliases",
  generator_location = "starlette/BUILD.bazel:5:12",
  actual = select({"@pypi//_config:is_cp313": "@@rules_python++pip+pypi_313_starlette//:whl", "//conditions:default": "@pypi//starlette:_no_matching_repository"}),
)
# Rule whl instantiated at (most recent call last):
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++pip+pypi/starlette/BUILD.bazel:5:12        in <toplevel>
#   /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python+/python/private/pypi/pkg_aliases.bzl:204:14 in pkg_aliases
```

It's just aliases to a repo created by whl_library.

## rules_py

### py_binary

`py_binary` rule is implemented in [py/private/py_binary.bzl](https://github.com/aspect-build/rules_py/blob/8a38744d51110a506b783000ba0f0913bb189f09/py/private/py_binary.bzl#L17)

```shell
$ bazel query 'deps(//web:cmd)'
<redacted>
@@rules_python++pip+pypi_313_fastapi//:pkg
@@rules_python++pip+pypi_313_pydantic//:pkg
<redacted>
```
py_binary depends on py_library targets that are specified as `deps`. Duh.

```shell
$ bazel cquery --output=files //web:cmd
bazel-out/darwin_arm64-fastbuild/bin/web/cmd
web/cmd.py
bazel-out/darwin_arm64-fastbuild/bin/web/cmd.venv.pth
```

One of the output files of py_binary is a cmd.venv.pth file that contains paths to all dependencies:

```shell
$ cat bazel-out/darwin_arm64-fastbuild/bin/web/cmd.venv.pth
../../../..
../../../../rules_python++pip+pypi_313_bazel_runfiles/site-packages
../../../../rules_python++pip+pypi_313_annotated_types/site-packages
../../../../rules_python++pip+pypi_313_typing_extensions/site-packages
../../../../rules_python++pip+pypi_313_pydantic_core/site-packages
<redacted>
```

TODO: why `../../../..` prefix?
TODO: what is bazel-bin/

`bazel-out/darwin_arm64-fastbuild/bin/web/cmd` is another output of a `py_binary, it's a bash script
that is built from a [template](https://github.com/aspect-build/rules_py/blob/main/py/private/run.tmpl.sh)