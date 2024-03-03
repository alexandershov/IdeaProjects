def _download_repo_rule_impl(repository_ctx):
    # dynamically configure a repository using repository_ctx
    print("downloading", repository_ctx.attr.url)
    response = repository_ctx.download(
        url = repository_ctx.attr.url,
        # downloads file to the specified path
        output = "downloaded",
        sha256 = repository_ctx.attr.sha256,
    )
    if not response.success:
        fail("could not download", repository_ctx.attr.url)

    # dynamically adds file to repo with the given content
    repository_ctx.file(
        "BUILD.bazel",
        content = """exports_files(["downloaded"])""",
    )

# repository_rule returns a repository
_download = repository_rule(
    implementation = _download_repo_rule_impl,
    attrs = {
        "url": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
    },
)

def _download_impl(module_ctx):
    _download(
        # name is a standard argument in repository rules, no need to define it in
        # attrs of `repository_rule`
        name = "leetcode_problem",
        url = "https://raw.githubusercontent.com/alexandershov/IdeaProjects/main/leetcode/coin_change_ii.py",
        sha256 = "a37d6e58a856a34936401efe279a629e58abd5441faff3985261359b4ea1e0d1",
    )

# module extension can be used by use_extension in MODULE.bazel
# module extension generates one or more repository rules
download = module_extension(
    implementation = _download_impl,
)
