def _download_repo_rule_impl(repository_ctx):
    # dynamically configure a repository using repository_ctx
    # this is executed during loading phase
    # and can access filesystem/network/etc
    # dynamic_deps contains labels with canonical repo names, so they can be used
    # across repos
    dynamic_deps = repository_ctx.read(repository_ctx.attr.deps_file).split("\n")
    print("dynamic_deps = ", dynamic_deps)

    print("downloading", repository_ctx.attr.url)
    response = repository_ctx.download(
        url = repository_ctx.attr.url,
        # downloads file to the specified path
        output = "downloaded",
        sha256 = repository_ctx.attr.sha256,
    )
    if not response.success:
        fail("could not download", repository_ctx.attr.url)

    repository_ctx.file(
        "print_data.py",
        content = repository_ctx.read(Label("//:print_data.py")),
    )

    # dynamically adds file to repo with the given content
    content = """
exports_files(["downloaded"])

py_binary(
    name = "print_data",
    srcs = ["print_data.py"],
    data = {},
)""".format(dynamic_deps)
    print("content = ", content)
    repository_ctx.file(
        "BUILD.bazel",
        content = content,
    )

# repository_rule returns a repository
_download = repository_rule(
    implementation = _download_repo_rule_impl,
    attrs = {
        "url": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
        "deps_file": attr.label(mandatory = True),
    },
)

def _download_impl(module_ctx):
    # iterate over all modules that use this extension
    for mod in module_ctx.modules:
        for do in mod.tags.do:
            _download(
                # name is a standard argument in repository rules, no need to define it in
                # attrs of `repository_rule`
                name = do.name,
                url = do.url,
                sha256 = do.sha256,
                deps_file = do.deps_file,
            )

# module extension can be used by use_extension in MODULE.bazel
# module extension generates one or more repository rules
download = module_extension(
    implementation = _download_impl,
    # we can `call` this extension as download.call(name="", url="", sha256="")
    tag_classes = {"do": tag_class({"name": attr.string(), "url": attr.string(), "sha256": attr.string(), "deps_file": attr.string()})},
)
