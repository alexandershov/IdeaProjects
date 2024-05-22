# starlark has unittest framework

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load(":rules.bzl", "double")

def _double_test_impl(ctx):
    # with typical legendary bazel ease of use you wrap your test in begin/end calls
    env = unittest.begin(ctx)
    asserts.equals(env, 6, double(3))
    return unittest.end(env)

rules_test = unittest.make(_double_test_impl)

# this testsuite is used in BUILD.bazel
def rules_test_suite(name):
    unittest.suite(name, rules_test)
