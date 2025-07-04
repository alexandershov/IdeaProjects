def _pie_binary_impl(ctx):
    interpreter = ctx.toolchains["@rules_python//python:toolchain_type"].py3_runtime.interpreter
    # executable will contain script like
    # `../rules_python++python+python_3_13_aarch64-apple-darwin/bin/python3 rules_pie/hello.py`
    executable = ctx.actions.declare_file(ctx.attr.name)
    ctx.actions.expand_template(
        template = ctx.files._bootstrap_template[0],
        output = executable,
        substitutions = {
            # use File.short_path to reference file at runtime
            # use File.path to reference file at exec time
            "{INTERPRETER}": interpreter.short_path,
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
                files = ctx.files.srcs + [interpreter],
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
    return [
        DefaultInfo(runfiles = ctx.runfiles(files = ctx.files.srcs))
    ]


pie_binary = rule(
    implementation = _pie_binary_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".py"]),
        "deps": attr.label_list(),
        # works together with transition
        "python_version": attr.string(),
        "_bootstrap_template": attr.label(default="bootstrap.sh.tpl", allow_files = True)
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
        "srcs": attr.label_list(allow_files = [".py"])
    }
)