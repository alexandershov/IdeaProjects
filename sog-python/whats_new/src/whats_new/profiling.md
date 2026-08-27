# Profiling


## What is it
Python 3.15 got a sampling profiler - tachyon.
It's low overhead compared to deterministic profilers - ~3% CPU on 1KHz sampling (default).

## Usage

### Sync
Start some program:

```shell
uv run src/whats_new/work.py
pid=23890
```

Attach sampling profiler to a running process (it needs sudo or some com.apple.security.cs.debugger/ptrace to do that):
```shell
sudo uv run python -m profiling.sampling attach 23890 --live
```

### Async
Start some async program:
```shell
uv run src/whats_new/async_work.py
pid=23682
```

Attach sampling profiler to a running process:
```shell
sudo uv run python -m profiling.sampling attach 23682 --live --async-aware
```
With `--async-aware` tachyon will reconstruct async task stacks instead of giving you the internals of event loop.





