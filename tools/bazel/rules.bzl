def _my_rule_impl(ctx):
    # this is called during the analysis phase
    print("analyzing", ctx.label)
    print("workspace", ctx.workspace_name)
    print("deps", ctx.attr.deps)
    if ctx.attr.deps:
        # deps[0] is a Target, that has attribute .files
        # which is a list with this Target output files
        print("deps[0]", ctx.attr.deps[0].files)

    # declare a file and write something to it
    # actually ctx.actions.write doesn't write to the file
    # it registers an action that will write to the file
    # the action will execute during the execution phase
    # so if we run `bazel cquery --output=files :all`
    # then although this _my_rule_impl will get executed
    # no files will be created/written to
    # merely an action will be registered
    out = ctx.actions.declare_file(ctx.label.name)
    out_1 = ctx.actions.declare_file(ctx.label.name + "_1_" + ctx.attr.platform)
    ctx.actions.write(output = out, content = "Hello %s\n" % ctx.attr.username)

    # .expand_template doesn't need to store template string in memory
    ctx.actions.expand_template(
        output = out_1,
        template = ctx.file._template,
        substitutions = {"{NAME}": ctx.attr.username.upper()},
    )

    # this tells bazel that out and out_1 are really a rule output, not just
    # some temporary files
    return [DefaultInfo(files = depset([out, out_1]))]

my_rule = rule(
    implementation = _my_rule_impl,
    # attributes to the rule
    attrs = {
        "username": attr.string(mandatory = True),
        # starts with underscore, private attribute
        # can be accessed as ctx.file._template
        "_template": attr.label(allow_single_file = True, default = "hello.tp"),
        # in a BUILD deps are used in a string
        # in a rule implementation it will be a Target
        # allow_files allows us specify files as deps
        # without allow_files = True you can only pass targets
        # allow_files can also be a list of allowed file extensions
        "deps": attr.label_list(allow_files = True),
        "platform": attr.string(mandatory = True),
    },
)

# when name starts with an underscore it can't be used in other modules
# compared to Python this behaviour is strictly enforced
_private = []

# you can modify this variable only during the loading of this file
immutable_outside_of_this_file = []

def double(x):
    return x + x

def change():
    immutable_outside_of_this_file.append(1)

change()

print("bazel file evaluation")
