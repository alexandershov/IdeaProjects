# SNOBOL

## What is it?
SNOBOL is a string-processing oriented language.
It's a very interesting language: essentially, it's an improvement over regexes:
* patterns are first-class and can be composed
* patterns can be recursive

There's no control flow except for goto based on pattern succeeding or failing.

See [main.sno](./main.sno) for a walkthrough of SNOBOL4 features.


## Install
SNOBOL went through several versions, SNOBOL4 is the latest (released in 1967) OG version.
```shell
brew install snobol4
```

## Usage
```shell
echo from_stdin | snobol4 main.sno
```