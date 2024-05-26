# aspects allow you to copy some part of a target graph across some target attributes
# and add new information to the graph nodes

# Bazel builds target graph based on label or label_list attributes
# aspect propagates based on a set of attributes (usually it's `deps`, but it can be any attribute)
# you can add info from aspect rule to aspect with `attrs` attribute in aspect definition

# let's make an aspect that will count number of sources

DepsCountInfo = provider(
    fields = {
        "count": "number of deps",
    },
)

def _deps_count_aspect_impl(target, aspect_ctx):
    count = 0
    if hasattr(aspect_ctx.rule.attr, "srcs"):
        for src in aspect_ctx.rule.attr.srcs:
            for f in src.files.to_list():
                # aspect_ctx.attr.extension is propagated starting from aspect rule to
                # the aspect
                if f.extension == aspect_ctx.attr.extension:
                    count += 1
    for dep in aspect_ctx.rule.attr.deps:
        count += dep[DepsCountInfo].count
    return [
        DepsCountInfo(count = count),
    ]

deps_count_aspect = aspect(
    # attr .extensions will propagate with aspect
    # values are allowed values
    attrs = {
        "extension": attr.string(values = ["py", "c"]),
    },
    implementation = _deps_count_aspect_impl,
    # list of attributes that aspect propagates through
    attr_aspects = ["deps"],
)

def _deps_count_rule_impl(ctx):
    for dep in ctx.attr.deps:
        print("count({}) = {}".format(dep, dep[DepsCountInfo].count))

# see usage of this rule in BUILD.bazel
# building this rule essentially triggers aspects machinery
deps_count_rule = rule(
    implementation = _deps_count_rule_impl,
    attrs = {
        # we pass a list of aspects applying to this rule
        "deps": attr.label_list(aspects = [deps_count_aspect]),
        "extension": attr.string(),
    },
)
