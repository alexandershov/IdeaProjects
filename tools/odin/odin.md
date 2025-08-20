## Odin

### What is it?

Odin is (another) modern C alternative.

### Install

Not sure if there is official brew formula, so let's just download it from github
```shell
curl -OL https://github.com/odin-lang/Odin/releases/download/dev-2025-08/odin-macos-arm64-dev-2025-08.zip
unzip odin-macos-arm64-dev-2025-08.zip
tar zxfv dist.tar.gz
odin-macos-arm64-nightly+2025-08-05/odin version
```

### Usage

See [main.odin](./main.odin) for an example. Run it with:
```shell
odin run .
```