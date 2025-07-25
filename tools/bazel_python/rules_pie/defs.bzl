load("@rules_python//python:defs.bzl", "PyInfo")

def _pie_binary_impl(ctx):
    """
    do I want to create proper venv here?
    If not, then I'll just reinvent venvs.

    Actually, the question is: do I want to create venv during the bootstrap script execution or during the build phase?
    Why tf should it happen during the bootstrap script execution?

    Min venv stuff:
      pyvenv.cfg
      bin/python
      lib/python{version}/site-packages

    Possible options for venv:
      lib/python{version}/site-packages/
         path.pth (contains paths to wheels)
         wheel-1.whl
         wheel-2.whl

      lib/python{version}/site-packages/
         unpacked-wheel-1/
         unpacked-wheel-2/

    .whl option is a hack, that's not idiomatic python.
    """

    py3_runtime = ctx.toolchains["@rules_python//python:toolchain_type"].py3_runtime
    interpreter = py3_runtime.interpreter
    # executable will contain script like
    # `../rules_python++python+python_3_13_aarch64-apple-darwin/bin/python3 rules_pie/hello.py`
    executable = ctx.actions.declare_file(ctx.attr.name)

    pyvenv_cfg = ctx.actions.declare_file("pyvenv.cfg")
    ctx.actions.write(output=pyvenv_cfg, content="include-system-site-packages = false")

    venv_python = ctx.actions.declare_file("bin/python")
    ctx.actions.symlink(output = venv_python, target_file = interpreter)

    site_packages_dir = "lib/python{}.{}/site-packages".format(
            py3_runtime.interpreter_version_info.major, py3_runtime.interpreter_version_info.minor)
    site_packages_pth = ctx.actions.declare_file("{}/paths.pth".format(site_packages_dir))

    # site-packages dir is e.g. "path/in/workspace/lib/python3.13/site-packages"
    # we need to constuct relative path in paths.pth so
    # os.path.join("path/in/workspace/lib/python3.13/site-packages", path_in_paths_pth) == ""
    # this way our binary can do `import path.in.workspace`
    # the way to construct relative path is to negate each path component of site-packages dir with ..
    # number of path components is number of slashes + 1

    # `- 1` discards a slash before `paths.pth`, so we have a slash count in
    # site-packages dir ("path/in/workspace/lib/python3.13/site-packages") and not in
    # "path/in/workspace/lib/python3.13/site-packages/paths.pth"
    num_slashes_in_site_packages_dir = site_packages_pth.short_path.count("/") - 1
    num_components = num_slashes_in_site_packages_dir + 1
    ctx.actions.write(output = site_packages_pth, content = "/".join([".." for _ in range(num_components)]))

    ctx.actions.expand_template(
        template = ctx.file._bootstrap_template,
        output = executable,
        substitutions = {
            # use File.short_path to reference file at runtime
            # use File.path to reference file at exec time
            "{INTERPRETER}": venv_python.short_path,
            "{MAIN_SCRIPT}": ctx.files.srcs[0].short_path,
        },
        is_executable = True,
    )
    runfiles = []
    seen_paths_in_site_packages = set() # set appeared in bazel 8.1
    # TODO: clean up creating of symlinks in site-packages
    for dep in ctx.attr.deps:
        if PyInfo in dep:  # rules_python's py_(library|binary|test)
            for file in dep[DefaultInfo].default_runfiles.files.to_list():
                if "site-packages/" in file.short_path:
                    start = file.short_path.rindex("site-packages/")
                    path_in_site_packages = file.short_path[start:].removeprefix("site-packages/")
                    if path_in_site_packages in seen_paths_in_site_packages:
                        continue
                    seen_paths_in_site_packages.add(path_in_site_packages)
                    path = ctx.actions.declare_file("{}/{}".format(site_packages_dir, path_in_site_packages))
                    ctx.actions.symlink(output = path, target_file = file)
                    runfiles.append(path)
    deps_runfiles = depset(transitive=[dep[DefaultInfo].default_runfiles.files for dep in ctx.attr.deps])

    return [
        DefaultInfo(
            # executable is a special attribute that would be added to `files` attribute of DefaultInfo
            executable = executable,
            runfiles = ctx.runfiles(
                files = ctx.files.srcs + [interpreter, pyvenv_cfg, venv_python, site_packages_pth] + runfiles,
                transitive_files=deps_runfiles
            ),
        )
    ]

def _python_version_transition_impl(settings, attr):
    if attr.python_version:
        return {"@rules_python//python/config_settings:python_version": attr.python_version}


# python_version_transition can change python version based on attr.python_version
python_version_transition = transition(
    implementation = _python_version_transition_impl,
    inputs = [],
    # `outputs` specify which configuration parameters this transition is allowed to change
    outputs = ["@rules_python//python/config_settings:python_version"],
)

def _pie_library_impl(ctx):
    deps_runfiles = depset(transitive=[dep[DefaultInfo].default_runfiles.files for dep in ctx.attr.deps])

    return [
        DefaultInfo(runfiles = ctx.runfiles(files = ctx.files.srcs, transitive_files = deps_runfiles))
    ]


pie_binary = rule(
    implementation = _pie_binary_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".py"]),
        "deps": attr.label_list(),
        # works together with transition
        "python_version": attr.string(),
        "_bootstrap_template": attr.label(default="bootstrap.sh.tpl", allow_single_file = True),
    },
    # with `executable = True` you can `bazel run <target>`
    executable = True,
    toolchains = ["@rules_python//python:toolchain_type"],
    # cfg defines transition
    cfg = python_version_transition,
)


pie_library = rule(
    implementation = _pie_library_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".py"]),
        "deps": attr.label_list(),
    }
)