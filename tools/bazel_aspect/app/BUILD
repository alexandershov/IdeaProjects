load("@aspect_rules_py//py:defs.bzl", "py_binary", "py_test")

py_binary(
    name = "app_bin",
    srcs = ["__main__.py"],
    main = "__main__.py",
    visibility = ["//:__subpackages__"],
    deps = ["@pip//requests"],
)

py_test(
    name = "test_add",
    srcs = ["test_add.py"],
    deps = ["@pip//pytest"],
)
