## Bazel Summer 2025 Study Plan

* rules_python deep-dive
  * how wheels are created
  * https://android.googlesource.com/platform/external/bazelbuild-rules_python/+/73e2490/README.md
  * understand toolchains in rules_python (e.g. @rules_python//python/config_settings:is_python_3.9)
  * etc
* rules_py deep-dive
  * helpers to reuse rules_py rules (py_binary/py_library)
  * etc
* runfiles deep-dive
  * bash, python, and cpp implementations of runfiles lib 
  * etc
* writing rules
  * https://www.youtube.com/watch?v=2KUunGBZiiM (jay conrod on writing rules)
  * https://bazel.build/rules/lib/builtins/ctx & dfs for all arguments from there 
  * https://github.com/bazel-contrib/rules-template
  * when bazel builds an action graph, how it can actually understand which actions are in a graph? I.e. what tf does it mean to execute rule implementation, if it's actually hermetic?
  * providers
  * etc
* https://bazel.build/start (look at "Build concepts")
* starlark
  * ✅ `[added package_group & subpackages]` https://bazel.build/reference/be/functions
  * ✅ `[nothing interesting]` https://bazel.build/rules/bzl-style
  * etc
* https://bazel.build/configure/best-practices
* ✅ https://bazel.build/contribute/codebase  
* configurations https://bazel.build/extending/config
* ✅ apparent/canonical repo names
* gazelle
  * general
  * python
* coverage deep-dive
  * what does --experimental_use_llvm_covmap do? 
  * etc
* https://blog.engflow.com/2024/05/13/the-many-caches-of-bazel/#in-memory-caches
* toolchains deep-dive
* aspects
* rule transitions https://bazel.build/extending/config
* rules_oci
* rules_proto for python deep-dive
  * why do we need proto_library
  * etc
* sandboxing
* bazel & envvars
* integration testing & bazel from dropbox: https://www.youtube.com/watch?v=muvU1DYrY0w
* CTC https://www.youtube.com/watch?v=9Dk7mtIm7_A
* ecosystem
  * skylib: https://github.com/bazelbuild/bazel-skylib
  * aspect skylib: https://github.com/bazel-contrib/bazel-lib
* cquery
  * output=starlark
  * deep-dive
* debugging & performance
  * https://blog.aspect.build/diagnose-cache-misses-1
  * https://bazel.build/remote/cache-remote#troubleshooting-cache-hits
  * https://blog.aspect.build/bazel-oom
  * https://bazel.build/versions/8.0.0/advanced/performance/build-performance-breakdown
  * https://bazel.build/rules/performance
  * bazel profiling (BPE, etc)
* buildozer
* buildifier
* [build systems a la carte](https://www.microsoft.com/en-us/research/wp-content/uploads/2018/03/build-systems.pdf)
  * understand why we need intermediate static files to have dynamic dependencies in bazel?
* hermetic_cc_toolchain
* ibazel https://github.com/bazelbuild/bazel-watcher
* aspect blog https://blog.aspect.build
* https://earthly.dev/blog/bazel-build/ "When to use bazel"
* rules_lint: https://www.youtube.com/watch?v=CnK-RAdfrpI 
* useful cmdline options
  * --override_repository 
  * --subcommands
  * how --nobuild_runfiles_links interacts with loading/analysis phase
  * etc
* videos from bazelcon 20**
* bazel downloader
  * https://blog.aspect.build/configuring-bazels-downloader 
  * rewrite urls
  * etc
