## Python packaging

### Prerequisites

Let's download wheel for uvloop:

```shell
curl -OL https://files.pythonhosted.org/packages/3f/8d/2cbef610ca21539f0f36e2b34da49302029e7c9f09acef0b1c3b5839412b/uvloop-0.21.0
-cp313-cp313-macosx_10_13_universal2.whl
```

Let's download sdist for uvloop

```shell
curl -OL https://files.pythonhosted.org/packages/af/c0/854216d09d33c543f12a44b393c402e89a920b1a0a7dc634c42de91b9cf6/uvloop-0.21.0.tar.gz
```

Here are our files:

```shell
➜  packaging_playground ls | cat
uvloop-0.21.0-cp313-cp313-macosx_10_13_universal2.whl
uvloop-0.21.0.tar.gz
```

### Wheel

### Sdist