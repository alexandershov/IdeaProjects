# Koka

## What is it?
Koka is an experimental programming language that has support for algebraic effects.

See [main.kk](./main.kk) for a concrete example of effects.

Effects allow to implement exceptions, async/await, generators, coroutines using the same abstraction.
On a high level it works like this: effect is kinda like an interface that can have several methods.

E.g. effect `raise` (this is idealized javascript slash pseudocode):
```
with effect raise {
   raise exc 
   print()
} on raise {
    do_something
}
```

That was exactly like exceptions. But with effects you can jump back to the place that performed an effect.
E.g. here are coroutines/coroutines implemented with effects:
```
with effect yield {
    x = yield y
    print(x)
} on yield v {
    resume(v * 2)
}
```

`on` doesn't need to be in the callstack level as performing an effect.

We can implement kinda colorless async/await:
```
with effect  {
    resp = fetch(url)
    print(resp.data)
} on fetch url {
    event_loop = get_or_create_event_loop()
    event_loop.on_fetch(url, resp => resume(resp))
}
```

Kinda colorless is because we can set sync or async effect handlers. It's essentially dependency injection
like zig new async stuff.

Btw effects can be used as dependency injection, as replacement for globals, as passing through context implicitly.
Async example actually contains all of these.

Effects are similar to CL condition system, but are more abstract, because you can resume the same effect several times.
They are also more friendly to static typing and have better composability than monads (citation needed).

## Install
```shell
brew install koka
```

## Usage
```shell
koka main.kk -o main && chmod +x main && ./main
```