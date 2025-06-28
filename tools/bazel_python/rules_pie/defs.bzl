def _pie_binary_impl(ctx):
    outputs = []
    interpreter = ctx.toolchains["@rules_python//python:toolchain_type"].py3_runtime.interpreter
    for src in ctx.files.srcs:
        output = ctx.actions.declare_file(src.path)
        outputs.append(output)
        # TODO: is there a better way to copy srcs to outputs than run_shell?
        ctx.actions.run_shell(
            inputs = [src],
            outputs = [output],
            command = "cp {} {}".format(src.path, output.path),
        )
    executable = ctx.actions.declare_file(ctx.attr.name)
    ctx.actions.expand_template(
        template = ctx.files._bootstrap_template[0],
        output = executable,
        substitutions = {
            # TODO: understand difference between File.path & File.short_path
            "{INTERPRETER}": interpreter.short_path,
            "{MAIN_SCRIPT}": outputs[0].short_path,
        },
        is_executable = True,
    )
    return [
        DefaultInfo(
            executable = executable,
            files = depset(direct = outputs + [executable]),
            runfiles = ctx.runfiles(files = ctx.files.srcs + [interpreter] + [outputs[0]]))
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