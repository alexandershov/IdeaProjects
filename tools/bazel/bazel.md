## Bazel
Bazel is a language-agnostic build system. 

You write build rules in Starlark.

Starlark is basically a heavily restricted subset of Python.

Bazel allows you to describe dependencies and run rules only when rule inputs change.

Bazel uses cache to speed up build process. It caches downloaded files, rule ouputs etc.
Cache is implemented as Content Addressable Storage similar to git.

Install:
```shell
brew install bazelisk
```

Bazelisk is a wrapper around bazel, that can download the required version
of bazel and run it.

You can specify bazel version you want to use in .bazelversion.
Bazel has 2 kind of releases:
* LTS, you should use them
* Rolling releases (built from HEAD about every two weeks, see [here](https://bazel.build/release/rolling) for a list of rolling releases)

Run target:
```shell
bazel run :print_leetcode_problem
```

See .bzl and .bazel files for how `:print_leetcode_problem` target is defined.


## Phases
Bazel does stuff in three phases, which are (mostly terribly) named Loading, Analysis, and Execution.

### Loading Phase
Bazel reads BUILD files. 
Repo rules are executed. During this phase you can do non-hermetic stuff: read files, access network, etc.
E.g. you can read a file and dynamically construct a repo based on this file content.
Macros are expanded.
Output of loading phase is a Build Graph: targets and their dependencies.
Yes, bazel knows dependencies of targets even without executing rule implementations.
It can (not 100% sure, but very probably) infer dependencies based on rule definitions:
if rule has an attribute of type `attr.label` then it's a dependency of the current rule.

`load` statements are also executed during the loading phase, this means that if you reference third-party repo in
a load statement, it will be eagerly fetched. So you need to be on a watchout for the eager load.
E.g. if `BUILD.bazel` contains a `load("@python_main_hub//:requirements.bzl", "requirement")` and target
`:my_rule_name_1` doesn't actually depend on `@python_main_hub`, then doing
```shell
bazel clean --expunge
bazel query :my_rule_name_1
```
will cause a fetch & materialization of `python_main_hub`:
```shell
ls $(bazel info output_base)/external/ | rg python_main_hub
@rules_python++pip+python_main_hub.marker
rules_python++pip+python_main_hub
```

You can prefetch all third-party stuff needed for a build:
```shell
bazel fetch //subpackage/...
```
This will fetch all out of source dependencies that are referenced by `//subpackage/...`
`--nofetch` option disables fetching, so after you've prefetched everything with `bazel fetch` you
can specify `--nofetch` and build will succeed without accessing network:
```
bazel run --nofetch //subpackage:check_runfiles
```

If something was not fetched before, you'll get an error:
```shell
bazel clean --expunge
bazel run --nofetch //subpackage:check_runfiles
Starting local Bazel server (8.2.1) and connecting to it...
ERROR: Error computing the main repository mapping: error during computation of main repo mapping: to fix, run
	bazel fetch //...
```

You can fetch dependencies of any repository, even third-party ones.
E.g. this will fetch all dependencies in third-party python hub:
```shell
 bazel fetch '@@rules_python++pip+python_main_hub//...'
```

You can trigger the loading phase with `bazel query`, e.g.:
```shell
bazel clean --expunge
# it won't execute rule implementation, there'll be no output from `print("analyzing", ctx.label)` in rule implementation
bazel query :my_rule_name_1 2>&1 | rg analyzing
<NOTHING>
```

### Analysis Phase
Ordinary rules are executed. Essentially implementation function of each rule is executed.
`select` calls are resolved. 
This phase is strictly deterministic. No IO actually takes place.
When you do `ctx.actions.write_file` in a rule implementation it doesn't actually write to file.
It just registers this action in an Execution Graph.
Output of analysis phase is Execution Graph: actions (e.g. write a file) and their dependencies.
Each action is a subprocess call (with some inputs & outputs)

You can trigger the analysis phase with 
```shell
bazel build --nobuild //...
```
`--nobuild` stops after analysis phase and doesn't actually execute actions.

Proof:
```shell
bazel clean --expunge
# --nobuild doesn't create an actual build 
bazel build --nobuild //subpackage:check_runfiles
ls bazel-bin/subpackage/
bazel-bin: No such file or directory

# without --nobuild we create a actual build
bazel build //subpackage:check_runfiles
ls bazel-bin/subpackage/ | wc -l
4
```

You can also trigger analysis with cquery, it executes rule implementation function:
```shell
bazel clean --expunge
bazel cquery :my_rule_name_1 2>&1 | rg analyzing
DEBUG: /Users/aershov/IdeaProjects/tools/bazel/rules.bzl:3:10: analyzing //:my_rule_name_1
```

### Execution Phase
Execution graph is, well, executed. 
Output of execution phase is a build: build files etc in bazel-out/ dir
Actions are executed only if their output is requested.
There are several execution strategies: https://bazel.build/docs/user-manual#execution-strategy
Default is sandboxed. Strategy can be configured with the `--spawn-strategy` 
E.g:
```shell
# fails because tries to write to a file outside of sandbox
bazel build :sandbox

# succeeds, because runs without a sandbox (local is just a subprocess without sandboxing)
bazel build --spawn_strategy=local :sandbox
```

When using sandbox, bazel creates a sandbox directory and executes code in it. 
When build finishes sandbox directory is cleaned.
You can pass `--sandbox_debug` to print extra debugging info (including path to sandbox directory), and
sandbox directory won't be cleaned.

You can also specify (`-s` or `--subcommands`, that will print commands that are executed).
With `--verbose_failures` bazel will print command that has failed. (it's like `--subcommands`, but only for
failed commands)

## Modules
bzlmod is a new system for managing bazel dependencies. See [MODULE.bazel](./MODULE.bazel) for a description of bzlmod.

Show bazel module dependency graph:

```shell
bazel mod graph
```

## Labels
Repos has globally unique names. They are called canonical repo names.
They are referred as @@<canonical name>. Main repo has empty canonical name and 
targets in the main repo can be referred as `@@//path/to:target`.
With @@ even external repos can reference targets in the main repo. 

Also repos have apparent names: essentially a local repo name that only works in the context of some other repo.
Each repo maintains a repo_mapping: {apparent_name -> canonical_name}.
So the same (by canonical name) repo can have two different apparent names in repo A and in repo B.

It's not clear how to inspect full repo_mapping for a given repo. One way to take a look at a _part_ of it
is to build some binary and to inspect `{name}.repo_mapping` in a build output:
```shell
bazel build //subpackage:py_cat
cat bazel-bin/subpackage/py_cat.repo_mapping
,bazel_tutorial,_main
rules_python++python+python_3_11_aarch64-apple-darwin,python_3_11_aarch64-apple-darwin,rules_python++python+python_3_11_aarch64-apple-darwin
```

Format of repo mapping is csv `X,A,C` meaning that in repo X you can refer to a repo with canonical name C 
using apparent name A.
If X is empty (like in the first line), then it's a main repo. 
So `bazel query @bazel_tutorial//...` works (`bazel_tutorial` taken from a module name in `module(name=)` call)
I'm not sure why `@@_main//...` doesn't work:
```shell
bazel query @@_main//...
ERROR: Target parsing failed due to unexpected exception: Repository '@@_main' is not defined
```

## Query

Find all rule names recursively
```shell
bazel query //...
```

Find all rule names and file names (source and generated) recursively.
```shell
bazel query '//...:*'
```

In addition to rule names `*` also matches file names, but it doesn't consider subpackages.
More info is available using this command:
```shell
bazel help target-syntax
```

Select targets by regex:
```shell
bazel query 'filter(".*check.*", //...)'
```

Find buildfiles (and `.bzl` files that they use) in packages of target set
```shell
bazel query 'buildfiles(//subpackage/...)'
```

Find targets having .py `srcs` (you can specify any rule attribute instead of `srcs`):
```shell
bazel query 'attr(srcs, "\.py\b", //...)'
```

Find `.bzl` files required to load packages of target set
```shell
bazel query 'loadfiles(//...)'
```

Find all dependencies of a target:
```shell
bazel query --notool_deps 'deps(:check_runfiles)'
```

Find all direct dependencies of a target, second argument of deps means depth
```shell
bazel query --notool_deps 'deps(:check_runfiles, 1)'
```

Find some dependency path between two targets
```shell
bazel query --notool_deps 'somepath(:check_runfiles, @bazel_tools//src/main/cpp/util:logging.cc)'
```

Find who depends on a target (aka "reversed dependencies")
```shell
bazel query --notool_deps 'rdeps(//..., check_runfiles.py)'
```

Find direct reversed dependencies in a same package:
```shell
bazel query 'same_pkg_direct_rdeps(//:check_runfiles)'
```

Find all targets in the same package:
```shell
bazel query 'siblings(//:check_runfiles)'
```

Find packages
```shell
bazel query '//...' --output=package
```

Find targets in newline-delimited json format
```shell
bazel query '//...' --output=streamed_jsonproto
```

Find targets with their source file location (file, lineno, column)
```shell
bazel query 'kind(rule, //...)' --output=location
```

Expand macros & globs
```shell
bazel query '//...' --output=build
```

Show build graph:
```shell
bazel query '//...' --output=graph | dot -Tsvg > /tmp/deps.svg
open /tmp/deps.svg
```

Find rules
```shell
bazel query 'kind("rule", //...)'
```

Find kinds of rules (kind is e.g. py_binary/py_library)
```shell
bazel query 'kind(rule, //...)' --output=label_kind
```

Find targets generated by a macro `py_test`
```shell
bazel query 'attr(generator_function, py_test, //...)'
```

Find files generated by rules
```shell
bazel query 'kind("generated file", //...:*)'
```

Find medium tests
```shell
bazel query 'attr(size, "medium", tests(//...))'
```

Find all tests
```shell
bazel query 'tests(//...)'
```

Find all source files in dependencies of a target. This includes also files in `data`.
```shell
bazel query 'kind("source file", deps(//:check_runfiles))' --noimplicit_deps
```

```shell
bazel query 'kind("generated file", //...)'
```

Find differences between dependencies
```shell
bazel query --notool_deps 'deps(//...) except deps(//subpackage/...)'
```

Find common things between dependencies (`//:*` are all targets in root package)
```shell
bazel query --notool_deps 'deps(//:*) intersect deps(//subpackage/...)'
```

List all platforms
```shell
bazel query @platforms//os:all
```

## cquery

cquery can run after analysis phase (query runs after loading phase) and so it knows about 
output files

```shell
bazel cquery --output=files :my_rule_name_1
```

This doesn't work as we don't know output files after loading phase:
```shell
# doesn't work
bazel query --output=files :my_rule_name_1
```

Executable path in bazel-out, can be joined with workspace_root to get the absolute path
(you can specify some starlark code in --starlark:expr)
```shell
bazel cquery --output=starlark --starlark:expr='target.files_to_run.executable.path' //:check_runfiles
```

Executable path in runfiles
```shell
bazel cquery --output=starlark --starlark:expr='target.files_to_run.executable.short_path' //:check_runfiles
```

cquery can resolve results of `select`
```shell
bazel cquery 'deps(:my_rule_name_2, 1)' --noimplicit_deps
```

query can't resolve results of `select` and conservatively outputs all possibilities
```shell
bazel query 'deps(:my_rule_name_2, 1)' --noimplicit_deps
```

Setting user-defined platforms
```shell
bazel cquery 'deps(:my_rule_name_2, 1)' --noimplicit_deps --platforms=//:rock_paper_scissors
```

cquery outputs configuration id, it's essentially a hash of all build options.

Show available configurations:
```shell
bazel config
```

View configuration (7170974 is short configuration id):
```shell
bazel config 7170974
```
Configuration is just a bunch of options.

You can cquery across given configuration:
```shell
bazel cquery 'config(//subpackage/... except //subpackage:adder, 7170974)'
```

## aquery
aquery allows you to query Execution Graph. It outputs actions.
You can see action inputs, outputs, and command line.

Show actions that are executed when building target 
(I use --noinclude* flags here, because rules_python rules output is huge without them):
```shell
bazel aquery '//:check_runfiles' --noinclude_commandline --noinclude_artifacts
```

Show actions that have input files matching regex:
```shell
bazel aquery 'inputs(".*py$", //...)' --noinclude_commandline --noinclude_artifacts
```

Show actions that have output files matching regex:
```shell
bazel aquery 'outputs(".*txt$", //...)'
```

You can chain action functions:
```shell
bazel aquery 'inputs(".*md", outputs(".*txt$", //...))'
```

You can query actions that are currently in-memory cache (Skyframe)
With typical bazel legendary easy of use it doesn't work with default output format and requires --output=*proto*
```shell
bazel aquery --skyframe_state --output=textproto 'outputs(".*txt")'
```

If we do `bazel shutdown` and then immediately run aquery with --skyframe_state we'll get nothing in return,
because cache is empty.

## Testing
You can set rerun flaky tests with:
```shell
bazel test --flaky_test_attempts=3 //subpackage:passing_test
```

By default, bazel runs all tests even if some tests are failed.
You can fail fast with:
```shell
# with --notest_keep_going `bazel test` exits immediately as soon as one test has failed. 
bazel test --notest_keep_going //...
```


## Coverage
See python.toolchain call in [MODULE.bazel](./MODULE.bazel) for coverage configuration for python.

Run coverage
```shell
 bazel coverage --combined_report=lcov //subpackage:passing_test
```

Coverage report will be available in bazel-out/_coverage/_coverage_report.dat

By default, test files are not instrumented for coverage, you can change that with
`--instrument_test_targets`
```shell
 bazel coverage --combined_report=lcov --instrument_test_targets //subpackage:passing_test
```

You can additionally specify which rules to instrument for coverage with
`--instrumentation_filter` which is a comma-separated list of target regexes
prefix regex with `-` to exclude mathing targets from instrumentation
```shell
 bazel coverage --combined_report=lcov --instrumentation_filter '//subpackage:b.*,-//subpackage:a.*' //subpackage:passing_test
```

## Directory structure
Bazel writes all of its data to a directory called `outputUserRoot`.
Its exact location differs across OSes.
On Linux it's `~/.cache/bazel/_bazel_${USER}`. On Mac it's `/private/var/tmp/_bazel_${USER}`
`outputUserRoot` contains:
* directories for each workspace (their names are md5 hashes of full paths to workspaces)
* `install/` directory containing installation of bazel (`bazel info install_base`)

Bazel writes output of builds in workspace to `{outputUserRoot}/{md5(workspace)}/execroot/_main/bazel-out`.
For convenience bazel creates symlink to this directory in `{workspace}/bazel-out`.
`bazel info output_path` == `{outputUserRoot}/{md5(workspace)}/execroot/_main/bazel-out`
`bazel info output_base` == `{outputUserRoot}/{md5(workspace)}`
output_base also contains:
* `action_cache/` directory. So action cache is per-workspace.
* `external/` directory containing all fetched external repositories

When running under bzlmod `{outputBase}/execroot` contains a _main/ folder.
_main is a name of the main repository in bzlmod.
All actions have cwd set to `{outputBase}/execroot` (a sandbox version of it).
execroot actually contains the main repo and all external repos in `execroot/_main/external`
So with execroot you get a "true monorepo" view of bazel where everything is hermetic and downloads of third-party packages are not required.

Show a bunch of information about bazel (output_base, install_base, workspace, etc)
```shell
bazel info --show_make_env
```

`bazel clean` cleans `action_cache/` and output_path:

```shell
➜  bazel git:(main) ✗ ls $(bazel info output_base)/action_cache | wc -l
       2
➜  bazel git:(main) ✗ ls $(bazel info output_path) | wc -l
       4
➜  bazel git:(main) ✗ bazel clean
INFO: Starting clean (this may take a while). Consider using --async if the clean takes more than several minutes.
➜  bazel git:(main) ✗ ls $(bazel info output_base)/action_cache | wc -l
ls: /private/var/tmp/_bazel_aershov/aa113e5d9cb7e4bbe0353cfbd569ece8/action_cache: No such file or directory
       0
➜  bazel git:(main) ✗ ls $(bazel info output_path) | wc -l
ls: /private/var/tmp/_bazel_aershov/aa113e5d9cb7e4bbe0353cfbd569ece8/execroot/_main/bazel-out: No such file or directory
       0
```

`bazel clean --expunge` removes the whole output_base
```shell
➜  bazel git:(main) ✗ file $(bazel info output_base)
/private/var/tmp/_bazel_aershov/aa113e5d9cb7e4bbe0353cfbd569ece8: directory
➜  bazel git:(main) ✗ bazel clean --expunge
INFO: Starting clean (this may take a while). Consider using --async if the clean takes more than several minutes.
➜  bazel git:(main) ✗ ls /private/var/tmp/_bazel_aershov/aa113e5d9cb7e4bbe0353cfbd569ece8
ls: /private/var/tmp/_bazel_aershov/aa113e5d9cb7e4bbe0353cfbd569ece8: No such file or directory
```


## Caching

### Content Addressable Storage (CAS)
Bazel uses content-addressable storage (CAS) similar to git.
All source files are in CAS. All target outputs are in CAS.


### Action Cache (AC)
Bazel builds action graph. It has Action Cache (AC). 
AC key (digestKey in `bazel dump --action_cache` output) is hash of action inputs (input files, envvars, command being executed). 
AC value are hashes of outputs.
AC is located in `$(bazel info output_base)/action_cache
Action cache is represented as binary files in a filesystem.
We can explore it with 
```shell
bazel dump --action_cache
<REDACTED>
4, bazel-out/darwin_arm64-fastbuild/bin/subpackage/check_runfiles.runfiles/MANIFEST:
      actionKey = 42fe00a77a7d0342400eff2e6835e4493f6fbb75e5817faf94532d2d4ba74340
      usedClientEnvKey = c5b0a5291dd76968098af9b86d3f7150f8f642e85ba6c5ec6070689cb9019082
      digestKey = 58f70aa79411ec1f3c7c273da469b17efa177e93fdf07e9816bb188b368a1344

      packed_len = 138
<REDACTED>
```
Since bazel expects all actions to be hermetic (i.e. each action should be a pure function from its inputs to its outputs), this
means that given inputs, bazel can look up if outputs are already in cache and skip actually
executing an action.

You can explore bazel action  graph with the `bazel aquery <...>`

### Repository Cache
There's also (terribly named) repository cache. Repository cache doesn't cache the whole repositories,
it just caches downloads (there are [plans](https://docs.google.com/document/d/1ZScqiIQi9l7_8eikbsGI-rjupdbCI7wgm1RYD76FJfM/edit?tab=t.0) to make a "true" repository cache. See you in 10 years.)
When you use some repository_rule (e.g. http_archive), then
it uses `ctx.download` or `ctx.download_and_extract` which uses repository cache under the hood.
You pass sha256 to these repo_rules and bazel don't download anything if given sha256 is already in cache. 
Even if you pass the wrong url, then you'll still get the data from repository cache if there's an
entry in cache with the given sha256.

Repository cache is located at directory `bazel info repository_cache`.
It's also CAS and is shared across different workspaces.

Repository cache is not affected by bazel clean:

```shell
➜  bazel git:(main) ✗ ls $(bazel info repository_cache)/content_addressable/sha256  | wc -l
      31
➜  bazel git:(main) ✗ bazel clean --expunge
INFO: Starting clean (this may take a while). Consider using --async if the clean takes more than several minutes.
➜  bazel git:(main) ✗ ls $(bazel info repository_cache)/content_addressable/sha256  | wc -l
Starting local Bazel server and connecting to it...
      31
```

You can specify repository_cache directory with `--repository_cache` option:
```shell
bazel build :print_leetcode_problem --repository_cache ~/tmp/bazel_repo_cache
```

### In-memory Cache
There's also in-memory cache.
When you do `bazel <command>` it actually starts or uses already started bazel server.
It's written in Java and stores build-graph in memory.
You can shutdown bazel server with `bazel shutdown`.
On the next CLI invocation bazel server will be started again.
Bazel server can execute only one command at a time. That's why you're getting all
these "Another Bazel command is running" when trying two execute two bazel commands in parallel.

You can inspect server info:
```shell
$ ls $(bazel info output_base)/server
cmdline              jvm.out              response_cookie      server_info.rawproto
command_port         request_cookie       server.pid.txt
```

cmdline is how the server was started, it's a long java invocation:
```shell
cat $(bazel info output_base)/server/cmdline
azel(bazel)--add-opens=java.base/java.lang=ALL-UNNAMED-Xverify:none-Djava.util.logging.config.file=/private/var/tmp/_bazel_aershov/aa113e5d9cb7e4bbe0353cfbd569ece8/javalog.properties-Dcom.google.devtools.build.lib.util.
<REDACTED>
```

command_port is host:port pair:
```shell
cat $(bazel info output_base)/server/command_port
[::1]:51919%
# bazel is started on localhost, ipv6, port 51919
lsof -i :51919
COMMAND   PID    USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
java    13763 aershov   53u  IPv6 <REDACTED>      0t0  TCP localhost:51919 (LISTEN)
```

PID from lsof output checks out:
```shell
cat $(bazel info output_base)/server/server.pid.txt
13763%
```

bazel CLI communicates with the server using gRPC. 
E.g. here's an [implementation](https://github.com/bazelbuild/bazel/blob/master/src/main/java/com/google/devtools/build/lib/runtime/commands/RunCommand.java?utm_source=chatgpt.com) of `bazel run`

Under the hood bazel maintains a DAG of a build, it's called SkyFrame.
You can inspect it with (warning: huge output):
```shell
bazel dump --skyframe=deps
```


### Local/Remote Cache
Cache can be local or remote. Local cache is, ahem, local and lives on a local host machine.
Remote cache is, ahem, remote, essentially it's cache on some remote host.
Aside from that there is little differences between local and remote cache. Especially if you ignore tags = ["no-remote-cache"] 
which considers local cache as totally different from remote.

Local cache location is specified via --disk_cache parameter:
```shell
bazel test //subpackage:passing_test  --disk_cache=~/.cache/bazel
```

Disk cache stores actions, CAS of output files, and stdout/stderr of actions.
ATTENTION: this is a separate cache from AC and CAS. 
Disk cache can be shared by different workspaces. And disk cache is not garbage collected,
so you need a separate process of cleaning it up.

Passing disk_cache='' disables disk cache. It's actually default behaviour.

## Platforms
Platforms is a named collection of constraint values.
Constraint value is e.g. `cpu is arm64`, `cpu is x86_64`, or `os is linux`.
In bazelspeak e.g. `cpu` is constraint_setting and e.g. `arm64/etc` is constraint_value.
constraint_setting is essentially the name of the enum class. 
And constraint_value are essentially possible values of the enum.
[platforms](https://registry.bazel.build/modules/platforms) module defines a universally useful constraint settings & values.

E.g, here's a cpu constraint_setting:
```shell
$ bazel query --output=build '@platforms//cpu:cpu'
constraint_setting(
  name = "cpu",
)
```

And here's a redacted list of possible cpu constraint values:
```shell
bazel query '@platforms//cpu/...'
...
@platforms//cpu:arm64
...
@platforms//cpu:x86_64
...
```

`@platforms` name is actually a misnomer (welcome to bazel), because it defines a bunch of constraint settings/values, but only one platform:
```shell
bazel query 'kind(platform, @platforms//...)'
@platforms//host:host
```

You can think of 3 kinds of platforms:
* Host Platform (system where you execute bazel commands)
* Execution Platform (system where bazel executes actions)
* Target Platform (system where artifacts that are built by bazel are actually running)

In the simplest case all three of these are the same (e.g. your development machine is linux, you build on linux, 
and your final binary runs on linux), but it's not necessarily the case (e.g. you can run bazel on Mac
and cross-compile for linux)

`@platforms//host` is a special platform that describes your Host:
```shell
$ bazel query --output=build 'kind(platform, @platforms//...)'
platform(
  name = "host",
  constraint_values = ["@platforms//cpu:aarch64", "@platforms//os:osx"],
)
```
aarch64 is the same as arm64:
```shell
$ bazel query --output=build '@platforms//cpu:arm64'
alias(
  name = "arm64",
  actual = "@platforms//cpu:aarch64",
)
```

`@platforms//host` is [implemented](https://github.com/bazelbuild/platforms/blob/9b6373db0cf97f991458d1fdc14f164c94d91db5/host/extension.bzl#L35-L60) with a repo_rule.

You can specify Host and Target platforms with cmd options `--host_platform` & `--platforms`.
Default value of `--host_platform` is `"@bazel_tools//tools:host_platform`.
It's an alias for `@platforms//host:host`:
```shell
bazel query --output=build '@bazel_tools//tools:host_platform'
alias(
  name = "host_platform",
  actual = "@platforms//host:host",
)
```
If `--platforms` is not specified, then it defaults to the value of `--host_platform`.
Since `--host_platform` always has a value that's why you have os & cpu always specified during a bazel invocation.

You can create targets that are compatible only with the given constraints with `target_compatible_with`, see
`//subpackage:linux_x86_64_passing_test` for an example.

Incompatible targets are skipped in ... expansion:
```shell
bazel test //subpackage/...
//subpackage:linux_x86_64_passing_test                                     SKIPPED
//subpackage:passing_test                                                PASSED in 0.3
```

If we try to build an incompatible target explicitly, then we'll get an error:
```shell
$ bazel test //subpackage:linux_x86_64_passing_test
ERROR: Analysis of target '//subpackage:linux_x86_64_passing_test' failed; build aborted: Target //subpackage:linux_x86_64_passing_test is incompatible and cannot be built, but was explicitly requested.
Dependency chain:
    //subpackage:linux_x86_64_passing_test (e5d0b4)   <-- target platform (@@platforms//host:host) didn't satisfy constraints [@@platforms//cpu:x86_64, @@platforms//os:linux]```
```

## Toolchains
Toolchains allow you to essentially get the effect of select() inside the `attr.label(default=)`.
select can't be used as value for default in `attr.label`.
Sometimes you want to get this effect: e.g. py_binary rule can contain implicit dependency on python interpreter.
(something like _interpreter=attr.label(default="//path/to:interpreter")). 
The problem is that interpreter can be different depending on the platform/cpu

Toolchains allow you to achieve essentially that. 
The extra advantage is that you can provide toolchains that the rule author didn't
think about. Disadvantage is that it's extra complexity and another entry in ever-growing collection of
bazel crutches.

## Profiling

You can generate profile data with bazel, use `--profile=` flag.

```shell
bazel test --profile=subpackage_passing_test.json //subpackage:passing_test
```
This will generate profile data in Chrome Trace Event Format, you can visualize it
on https://ui.perfetto.dev

Actually bazel creates a profile on _every_ run. `--profile` just overrides the profile location.
By default profile is created in `$(bazel info output_base)/command.profile.gz`:
```shell
bazel test //subpackage:passing_test
file $(bazel info output_base)/command.profile.gz 
/private/var/tmp/_bazel_aershov/aa113e5d9cb7e4bbe0353cfbd569ece8/command.profile.gz: gzip compressed data, original size modulo 2^32 205069
```

You can also inspect profile with `bazel analyze-profile $(bazel info output_base)/command.profile.gz`:

```shell
bazel clean
bazel test //subpackage:passing_test
bazel analyze-profile $(bazel info output_base)/command.profile.gz
=== PHASE SUMMARY INFORMATION ===

Total launch phase time                              0.027 s    0.50%
Total init phase time                                0.027 s    0.51%
Total target pattern evaluation phase time           0.013 s    0.24%
Total interleaved loading, analysis and execution phase time    5.384 s   98.74%
Total finish phase time                              0.000 s    0.01%
---------------------------------------------------------------------
Total run time                                       5.453 s  100.00%

Critical path (5.348 s):
       Time Percentage   Description
    1.99 ms    0.04%   action 'Creating source manifest for //subpackage passing_test'
    0.14 ms    0.00%   action 'Creating runfiles tree bazel-out/darwin_arm64-fastbuild/bin/subpackage/passing_test.runfiles'
    1.21 ms    0.02%   runfiles for //subpackage passing_test
    5.345 s   99.94%   action 'Testing //subpackage passing_test'
     
# now let's see a cached run (I've commented out `external` tag for a //subpackage:passing_test 
bazel test //subpackage:passing_test
bazel analyze-profile $(bazel info output_base)/command.profile.gz

=== PHASE SUMMARY INFORMATION ===

Total launch phase time                              0.027 s   25.30%
Total init phase time                                0.028 s   26.64%
Total target pattern evaluation phase time           0.012 s   12.01%
Total interleaved loading, analysis and execution phase time    0.038 s   35.64%
Total finish phase time                              0.000 s    0.41%
---------------------------------------------------------------------
Total run time                                       0.106 s  100.00%

Critical path (4.05 ms):
       Time Percentage   Description
    1.72 ms   42.47%   action 'Creating source manifest for //subpackage passing_test'
    0.15 ms    3.71%   action 'Creating runfiles tree bazel-out/darwin_arm64-fastbuild/bin/subpackage/passing_test.runfiles'
    1.42 ms   35.01%   runfiles for //subpackage passing_test
    0.76 ms   18.81%   action 'Testing //subpackage passing_test'
```

Note that `Testing` action in a second (cached) run is very fast.

`command.profile.gz` is just a compressed json:
```shell
cat $(bazel info output_base)/command.profile.gz | zcat | head -3
{"otherData":{"bazel_version":"release 8.2.1","build_id":"a35541f3-47e2-4797-8378-1b6987f00f53","output_base":"/private/var/tmp/_bazel_aershov/aa113e5d9cb7e4bbe0353cfbd569ece8","date":"2025-06-14T17:38:43.886276Z","profile_start_ts":1749922723886},"traceEvents":[
    {"name":"thread_name","ph":"M","pid":1,"tid":0,"args":{"name":"Critical Path"}},
    {"name":"thread_sort_index","ph":"M","pid":1,"tid":0,"args":{"sort_index":0}},
```

You can generate a more detailed profile (taking a big performance hit) with 
```shell
bazel build --record_full_profiler_data //subpackage:py_cat
```

## Starlark

### Standalone interpreter
You can install standalone starlark interpreter: https://github.com/google/starlark-go
```shell
$ go install go.starlark.net/cmd/starlark@latest
```

and then `starlark` binary will appear on the path:
```shell
➜  bazel git:(main) ✗ starlark
Welcome to Starlark (go.starlark.net)
>>> fail("error")
Traceback (most recent call last):
  <stdin>:1:5: in <expr>
Error in fail: fail: error
```
Disclaimer: this is not the same interpreter that is used by bazel, but it's pretty close.