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


### toolchains
You specify toolchains in MODULE.bazel like this:
```starlark
python = use_extension("@rules_python//python/extensions:python.bzl", "python")
python.toolchain(
    python_version = "3.11",
)
```


`python` module extension is implemented in [_python_impl](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/python.bzl#L275)

`toolchain` tag is parsed in [_create_toolchain_attr_structs](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/python.bzl#L643)

For each seen python_version inside of the `toolchain` tag rules_python [creates](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/python.bzl#L198-L203)
toolchain_name is `"python_" + python_version.replace(".", "_")`.

Then we call repo rule [python_register_toolchain](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/python.bzl#L294).
And we'll create repo for each toolchain using [python_repository](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/python_register_toolchains.bzl#L133)
Each repo will have a name `{rules_python_prefix}_{toolchain_name}_{platform_name}` e.g. `@@rules_python++python+python_3_13_aarch64-apple-darwin`

Repos created by `python_repository` have BUILD.bazel defined by [build_content](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/python_repository.bzl#L220)

E.g. (`cat /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++python+python_3_13_aarch64-apple-darwin/BUILD.bazel`)
```starlark
# Generated by python/private/python_repositories.bzl

load("@rules_python//python/private:hermetic_runtime_repo_setup.bzl", "define_hermetic_runtime_toolchain_impl")

package(default_visibility = ["//visibility:public"])

define_hermetic_runtime_toolchain_impl(
  name = "define_runtime",
  extra_files_glob_include = ["lib/**"],
  extra_files_glob_exclude = [
    "**/__pycache__/*.pyc*",
    "**/__pycache__/*.pyo*",
],
  python_version = "3.13.2",
  python_bin = "bin/python3",
  coverage_tool = "@python_3_13_aarch64-apple-darwin_coverage//:coverage",
)
```

and they [download](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/python_repository.bzl#L75-L88) files from astral-sh/python-standalone github repo,
e.g.: https://github.com/astral-sh/python-build-standalone/releases/download/20250317/cpython-3.13.2+20250317-aarch64-apple-darwin-install_only.tar.gz
This tar archive contains compiled python and stdlib files
Inside of the [define_hermetic_runtime_toolchain_impl](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/hermetic_runtime_repo_setup.bzl#L27C5-L27C43)
we call [py_runtime](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/hermetic_runtime_repo_setup.bzl#L196C5-L196C15)
that links to the files in this generated repository.

Then we [create](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/python.bzl#L302) pythons_hub repo
The most interesting part of this repo is a call to [py_toolchain_suite](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/toolchains_repo.bzl#L58)
It'll finally [make a call](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/py_toolchain_suite.bzl#L102) to `toolchain` and will define
a toolchain, e.g. (taken from `bazel query --output=build 'attr(@@rules_python++python+pythons_hub//...)`):

```starlark
toolchain(
  name = "_0005_python_3_13_aarch64-apple-darwin_toolchain",
  generator_name = "_0005_python_3_13_aarch64-apple-darwin_toolchain",
  generator_function = "py_toolchain_suite",
  generator_location = "/private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/external/rules_python++python+pythons_hub/BUILD.bazel:611:19",
  toolchain_type = "@rules_python//python:toolchain_type",
  target_compatible_with = ["@@platforms//os:macos", "@@platforms//cpu:aarch64"],
  target_settings = ["@@rules_python++python+pythons_hub//:_0005_python_3_13_aarch64-apple-darwin_version_setting_3.13.2"],
  toolchain = "@@rules_python++python+python_3_13_aarch64-apple-darwin//:python_runtimes",
)
```

toolchain_type `@rules_python//python:toolchain_type` is actually an [alias](https://github.com/bazel-contrib/rules_python/blob/049866442fee7bb54fcb1a09e920953a0666e4b3/python/BUILD.bazel#L324-L327) to
`@bazel_tools//tools/python:toolchain_type`.
`rules_py` [reuses](https://github.com/aspect-build/rules_py/blob/8a38744d51110a506b783000ba0f0913bb189f09/py/private/toolchain/types.bzl#L3C31-L3C58) the same toolchain 
and [adds](https://github.com/aspect-build/rules_py/blob/8a38744d51110a506b783000ba0f0913bb189f09/py/private/py_binary.bzl#L96)
toolchain files (i.e. stdlib, python_interpreter) to the runfiles. 

Note that `target_compatible_with` and `target_settings` specify that this toolchain will be resolved only on
darwin+arm64+python3.13.

So rule `@@rules_python++python+python_3_13_aarch64-apple-darwin//:python_runtimes` will be used on darwin+arm64 as part
of toolchain resolution.

`:python_runtimes` is defined by [py_runtime_pair](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/hermetic_runtime_repo_setup.bzl#L220)
which [returns](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/py_runtime_pair_rule.bzl#L48-L52) a ToolchainInfo satisfying the
[Holy Trinity](https://bazel.build/extending/toolchains) of bazel toolchains:
1. [py_runtime_pair](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/py_runtime_pair_rule.bzl#L75) is a rule returning ToolchainInfo
2. Each python_repository for each platform+versions contains a [target](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/hermetic_runtime_repo_setup.bzl#L219-L223) of the py_runtime_pair
3. python_hubs repo [contains calls](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/py_toolchain_suite.bzl#L101) to `toolchain` function

Default toolchain [passes](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/py_toolchain_suite.bzl#L55-L56) 
set_python_version_constraint = False and uses python_version = "", which [leads to using](https://github.com/bazel-contrib/rules_python/blob/4f5a693bb324cce5f4a1a4c240b300ec8b10057b/python/private/py_toolchain_suite.bzl#L68-L70)
`@rules_python//python/config_settings:python_version` == "" in a toolchain resolution.
So if you don't pass `@rules_python//python/config_settings:python_version`, then default toolchain wins.
Other toolchain lose when you don't pass `@rules_python//python/config_settings:python_version`, because
they specify not empty constraints on `@rules_python//python/config_settings:python_version`.

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

bazel-bin/ is a symlink to `bazel-out/{architecture}-fastbuild/bin`

`bazel-out/darwin_arm64-fastbuild/bin/web/cmd` is another output of a `py_binary, it's a bash script
that is built from a [template](https://github.com/aspect-build/rules_py/blob/main/py/private/run.tmpl.sh)

### venv
For each py_binary & py_test rules_py also [creates](https://github.com/aspect-build/rules_py/blob/5f6c518ba1340a8a9096f040f493415a463f2a7c/py/defs.bzl#L94) a target `{name}.venv`
`py_venv_link` is defined in [py_venv.bzl](https://github.com/aspect-build/rules_py/blob/5f6c518ba1340a8a9096f040f493415a463f2a7c/py/private/py_venv/py_venv.bzl#L381)
You can create virtual env by 
```
$ bazel run //web:cmd.venv
Linking: /private/var/tmp/_bazel_aershov/a7594f89b7e68f13499b9e23d7a54d78/execroot/_main/bazel-out/darwin_arm64-fastbuild/bin/web/.cmd.venv -> /Users/aershov/IdeaProjects/tools/bazel_python/.cmd.venv

To activate the virtualenv run:
    source /Users/aershov/IdeaProjects/tools/bazel_python/.cmd.venv/bin/activate

Link created!
```
This target essentially runs [link.py](https://github.com/aspect-build/rules_py/blob/5f6c518ba1340a8a9096f040f493415a463f2a7c/py/private/py_venv/link.py), which
creates a simple symlink `.{name}.venv` in cwd. It reuses py_binary venv machinery.

The real work is done by [venv_tool](https://github.com/aspect-build/rules_py/tree/main/py/tools/venv_bin), which is implemented in rust.
It's a [rust file](https://github.com/aspect-build/rules_py/blob/main/py/tools/venv_bin/src/main.rs).
Here's how it's called in a launcher template:
```shell
"${VENV_TOOL}" \
    --location "${VIRTUAL_ENV}" \
    --python "$(python_location)" \
    --pth-file "$(rlocation _main/web/cmd.venv.pth)" \
    --collision-strategy "error" \
    --venv-name ".cmd.venv"
```

Heavy lifting is done by [venv.rs](https://github.com/aspect-build/rules_py/blob/5f6c518ba1340a8a9096f040f493415a463f2a7c/py/tools/py/src/venv.rs).
Entry point is [create_venv](https://github.com/aspect-build/rules_py/blob/5f6c518ba1340a8a9096f040f493415a463f2a7c/py/tools/py/src/venv.rs#L18)
It's actually [calling](https://github.com/aspect-build/rules_py/blob/5f6c518ba1340a8a9096f040f493415a463f2a7c/py/tools/py/src/venv.rs#L48) uv rust crate to create virtual env
source code of this template is [here](https://github.com/aspect-build/rules_py/blob/5f6c518ba1340a8a9096f040f493415a463f2a7c/py/private/run.tmpl.sh#L41-L46).

## runfiles

Good (although incomplete) description: https://github.com/laszlocsomor/bazel/commit/21989926c1a002709ec3eba9ee7a992506f2d50a
Another good description for Fuchsia: https://fuchsia.googlesource.com/fuchsia/+/HEAD/build/bazel/BAZEL_RUNFILES.md?format%2F%2F
Description for bazel contributors: https://bazel.build/contribute/codebase#runfiles
Good description on how to implement ruleset with runfiles: https://jayconrod.com/posts/108/writing-bazel-rules--data-and-runfiles

```shell
bazel clean
bazel build //web:cmd 
# creates bazel-bin/web/cmd launcher and bazel-bin/web/cmd.runfiles with a runfiles tree
bazel clean
bazel build --nobuild_runfile_links //web:cmd 
# creates bazel-bin/web/cmd launcher and no cmd.runfiles
# but if you run
bazel run --nobuild_runfile_links //web:cmd 
# then although `bazel build` won't create .runfiles tree, run will materialize tree during run
# although if you're running built binary without `bazel run`, then .runfiles tree won't get created
```

TODO: rules_py runfiles (in py_library & py_binary)