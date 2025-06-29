def _pie_binary_impl(ctx):
    interpreter = ctx.toolchains["@rules_python//python:toolchain_type"].py3_runtime.interpreter
    # executable will contain script like
    # `../rules_python++python+python_3_13_aarch64-apple-darwin/bin/python3 rules_pie/hello.py`
    executable = ctx.actions.declare_file(ctx.attr.name)
    ctx.actions.expand_template(
        template = ctx.files._bootstrap_template[0],
        output = executable,
        substitutions = {
            # TODO: understand difference between File.path & File.short_path
            "{INTERPRETER}": interpreter.short_path,
            "{MAIN_SCRIPT}": ctx.files.srcs[0].short_path,
        },
        is_executable = True,
    )
    return [
        DefaultInfo(
            # executable is a special attribute that would be added to `files` attribute of DefaultInfo
            executable = executable,
            runfiles = ctx.runfiles(files = ctx.files.srcs + [interpreter]),
        )
    ]

pie_binary = rule(
    implementation = _pie_binary_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".py"]),
        "_bootstrap_template": attr.label(default="bootstrap.sh.tpl", allow_files = True)
    },
    # with `executable = True` you can `bazel run <target>`
    executable = True,
    toolchains = ["@rules_python//python:toolchain_type"],
)