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
    return [
        DefaultInfo(
            files = depset(direct = outputs),
            runfiles = ctx.runfiles(files = ctx.files.srcs + [interpreter]))
    ]

pie_binary = rule(
    implementation = _pie_binary_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = [".py"])
    },
    toolchains = ["@rules_python//python:toolchain_type"],
)