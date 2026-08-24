# Nix

## What is it?
Nix is a package manager for Unix systems. 
Main ideas are:
* Immutability - you don't install packages to a global /usr/bin/* or something similar, each package has its own place
* Content-addressable - each package has hash, that is derived from its recipe and its dependencies


## Install
In hindsight: don't install nix on Mac! Uninstall is quite involved with 7 manual steps: https://nix.dev/manual/nix/2.21/installation/uninstall
```shell
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
```

Add line `experimental-features = nix-command flakes` to your `~/.config/nix/nix.conf`, this will allow you
to use `nix shell|build|run` commands.


## Usage
### /nix/store
All nix packages are located in `/nix/store`
```shell
$ ls /nix/store | rg sqlite
lf2jf0ybr329dw3sfi15hd1brm1k0d2v-sqlite-3.53.3
```
Note that each package name contains a hash - it's a hash of package recipe and its dependencies.
It's kinda like bazel. So you can two different packages for sqlite having the same version.

### shell
You can start nix shell with the packages you want:
```shell
# my system has clang 17.0.0 installed globally
$ clang --version | rg 'clang version'
Apple clang version 17.0.0 (clang-1700.0.13.5)
# now let's start a nix shell
$ nix shell nixpkgs#clang_22
$ clang --version | rg 'clang version'
clang version 22.1.8
```

So clang from nix can coexist with global clang. And it can coexist with a bunch of different versions of clangs
in nix.


Clang in nix points to `/nix/store`:
```shell
$ which clang
/nix/store/xmx56z6yrr2z473nwc2jazbdld207i0m-clang-wrapper-22.1.8/bin/clang
```
`nix shell` starts a shell with a specially constructed $PATH that points to nix's clang. 

### Flake
Flake defines an interface of describing a project with its dependencies.

See [flake.nix](./flake.nix) for an example.

When you have a flake with `devShells` you can run `nix develop` which is kinda like `nix shell`
but instead of specifying what you want in a command line, you describe it in a flake.
You can also do other stuff in flake (like support `nix build` & `nix run`)