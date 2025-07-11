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

    # create empty .pth file, as a quick way to create site-packages/ directory without ctx.actions.run
    site_packages_pth = ctx.actions.declare_file("lib/python{}.{}/site-packages/paths.pth".format(
        py3_runtime.interpreter_version_info.major, py3_runtime.interpreter_version_info.minor))
    ctx.actions.write(output = site_packages_pth, content = "")

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

    deps_runfiles = depset(transitive=[dep[DefaultInfo].data_runfiles.files for dep in ctx.attr.deps])

    return [
        DefaultInfo(
            # executable is a special attribute that would be added to `files` attribute of DefaultInfo
            executable = executable,
            runfiles = ctx.runfiles(
                files = ctx.files.srcs + [interpreter, pyvenv_cfg, venv_python, site_packages_pth],
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
    deps_runfiles = depset(transitive=[dep[DefaultInfo].data_runfiles.files for dep in ctx.attr.deps])

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