# What is it?

Oz is concurrency-oriented language. Mozart is an implementation/runtime of Oz. 

Overall looks dead, last release was 8 years ago.

# Install

Linux:
```shell
curl -OL https://github.com/mozart/mozart2/releases/download/v2.0.1/mozart2-2.0.1-x86_64-linux.deb
sudo apt install ./mozart2-2.0.1-x86_64-linux.deb
```

# Usage
```shell
ozc -c main.oz && ozengine main.ozf
```

`ozc` is an Oz compiler. `ozengine` is a runner of compiled bytecode.

See [main.oz](./main.oz) for a sample of the most interesting features – which is declarative concurrency.
Also, it supports logic programming.