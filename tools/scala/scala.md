## Scala

Scala is a functional language that runs on JVM.

Install Scala on Apple Silicon
```shell
curl -fL https://github.com/VirtusLab/coursier-m1/releases/latest/download/cs-aarch64-apple-darwin.gz | gzip -d > cs && chmod +x cs && (xattr -d com.apple.quarantine cs || true) && ./cs setup
```

Run tutorial
```shell
scalac Tutorial.sc && scala Tutorial
```