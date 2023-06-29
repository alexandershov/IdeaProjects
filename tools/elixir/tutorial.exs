defmodule Tutorial do
    def add(x, y) do
        x + y
    end

    def ping() do
        receive do
            {:ping} -> IO.puts "pong"
            {:pong} -> IO.puts "ping"
        end
    end
end

# fn creates anonymous functions
sub = fn (x, y) -> x - y end
IO.puts Tutorial.add(4, 3)
IO.puts sub.(4, 3)
# {...} creates tuple, :ok is an atom (symbol), and lists can hold any type
# (elixir is dynamically typed)
# we can't do IO.puts on tuple, because tuple doesn't implement Chars protocol
IO.inspect {:ok, [1, 2, "abc"]}

# spawn created a new process
# this process is not an OS process, this is a lightweight BEAM/erlang process
# ... that you can send messages to
ping_pid = spawn (fn -> Tutorial.ping end)
IO.puts (Process.alive? ping_pid)
send(ping_pid, {:ping})

# `with` has monad-like behaviour
# when there's mismatch the current value is returned
with_result = with {:ok, data} <- {:ok, "some data"},
     {:ok, data} <- {:error, data},
     do: IO.puts "success!"

# prints {:error, data}
IO.inspect with_result

# Elixir has some macros but writing them is a bit of tedious compared to lisp
# https://elixir-lang.org/getting-started/meta/macros.html
