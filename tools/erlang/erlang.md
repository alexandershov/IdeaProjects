# Erlang

## What is it?
Erlang is a functional programming language. It contains a lot of building blocks for creating 
reliable distributed systems.

Although Erlang itself is quite slow, it cares about latency: 
e.g. there's no global GC, but there's per-process GC, so there are no big GC pauses.  

## Install
```shell
brew install erlang
```

## Usage
```shell
erlc tutorial.erl && erl -noshell -s tutorial main
```

## Live shell
You can connect to running program.

```shell
erlc tutorial.erl && erl -noshell -s tutorial main -sname myapp -setcookie secret
```

Then in another terminal:
```shell
erl -sname debug -setcookie secret -remsh myapp
```

That's it! You are connected to another process and can e.g. call some functions defined:
```shell
(myapp@Mac)1> tutorial:sum(3, 2).
5
```

## Supervisor trees
See [sup.erl](./sup.erl) & [worker.erl](./worker.erl) for an example of supervisor & worker.
The idea is that supervisor can watch workers, restart them if they die.
supervisors can be watched by other supervisors, hence supervisor trees.

So the fact that a worker dies is totally fine ("let it crash"), supervisor will take care of it.
It's not like go, where panic in a single goroutine stops everything. Erlang is more resilient: only worker will die.

Here's an example of a supervisor in action:
```shell
# compile worker
(debug@Mac)1> c(worker).
{ok,worker}
# compile supervisor
(debug@Mac)2> c(sup).
{ok,sup}
(debug@Mac)3> {ok, SupPid} = sup:start_link().
worker started!
{ok,<0.102.0>}
# so crash of shell process doesn't crash supervisor
(debug@Mac)4> unlink(SupPid).
<0.103.0>
(debug@Mac)5> gen_server:call(worker, {divide, 3, 2}).
handle call!
1.5
(debug@Mac)6> gen_server:call(worker, {divide, 3, 0}).
** Generic server worker terminating
** Last message in was {divide,3,0}
** When Server state == #{}
** Reason for termination ==
worker started!
# worker died, but was restarted!
(debug@Mac)7> gen_server:call(worker, {divide, 3, 2}).
handle call!
1.5
```