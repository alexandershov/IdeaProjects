# Copyright 2024 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"A semver version parser"

def _key(version):
    return (
        version.major,
        version.minor or 0,
        version.patch or 0,
        # non pre-release versions are higher
        version.pre_release == "",
        # then we compare each element of the pre_release tag separately
        tuple([
            (
                i if not i.isdigit() else "",
                # digit values take precedence
                int(i) if i.isdigit() else 0,
            )
            for i in version.pre_release.split(".")
        ]) if version.pre_release else None,
        # And build info is just alphabetic
        version.build,
    )

def _to_dict(self):
    return {
        "build": self.build,
        "major": self.major,
        "minor": self.minor,
        "patch": self.patch,
        "pre_release": self.pre_release,
    }

def _upper(self):
    major = self.major
    minor = self.minor
    patch = self.patch
    build = ""
    pre_release = ""
    version = self.str()

    if patch != None:
        minor = minor + 1
        patch = 0
    elif minor != None:
        major = major + 1
        minor = 0
    elif minor == None:
        major = major + 1

    return _new(
        major = major,
        minor = minor,
        patch = patch,
        build = build,
        pre_release = pre_release,
        version = "~" + version,
    )

def _new(*, major, minor, patch, pre_release, build, version = None):
    # buildifier: disable=uninitialized
    self = struct(
        major = int(major),
        minor = None if minor == None else int(minor),
        # NOTE: this is called `micro` in the Python interpreter versioning scheme
        patch = None if patch == None else int(patch),
        pre_release = pre_release,
        build = build,
        # buildifier: disable=uninitialized
        key = lambda: _key(self),
        str = lambda: version,
        to_dict = lambda: _to_dict(self),
        upper = lambda: _upper(self),
    )
    return self

def semver(version):
    """Parse the semver version and return the values as a struct.

    Args:
        version: {type}`str` the version string.

    Returns:
        A {type}`struct` with `major`, `minor`, `patch` and `build` attributes.
    """

    # Implement the https://semver.org/ spec
    major, _, tail = version.partition(".")
    minor, _, tail = tail.partition(".")
    patch, _, build = tail.partition("+")
    patch, _, pre_release = patch.partition("-")

    return _new(
        major = int(major),
        minor = int(minor) if minor.isdigit() else None,
        patch = int(patch) if patch.isdigit() else None,
        build = build,
        pre_release = pre_release,
        version = version,
    )
