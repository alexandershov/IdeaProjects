## Coq

Coq is a theorem proof system and dependently typed programming language.

Coq is written in OCaml. Opam is a OCaml package manager.

```shell
brew install opam
opam init
```

Install Coq

```shell
opam install coq
```

Run coqtop (interactive Coq)

```shell
coqtop
```

Then type `Load "add_0.v".` in the prompt.
The theorem will be (silently) loaded and proved by Coq.
If you change `n + 0 = n` to `n + 1 = n` then proof will fail with the
message `Unable to unify "n" with "S n"`.
