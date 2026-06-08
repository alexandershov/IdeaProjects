-module(tutorial).

% /0 is function arity
-export([main/0, sum/2]).

sum(X, Y) ->
    X + Y.

main() ->
    % spawn creates a lightweight process, it's not an OS process, it's managed by Erlang VM (called BEAM)
    AdderPid = spawn(fun Loop() ->
        receive
            % this is pattern matching, add is atom; From, X, Y are variables
            {add, From, X, Y} -> From ! {ok, X + Y},
            % We call ourselves recursively, so this process forever handles messages
            Loop()
        end
    end),

    spawn(fun() ->
        % ! sends a message to pid, it sends a message asynchronously
        % self() is pid of the current erlang process
        % processes interact by sending messages to each other
        AdderPid ! {add, self(), 3, 2},
        io:format("sent add~n"),
        receive
            Msg ->
                io:format("before~n"),
                io:format("received ~p~n", [Msg]),
                io:format("after~n")
            % {ok, Result} -> io:format("Result = ~B~n", [Result])
        end
    end),

    receive
        Msg ->
            io:format("[main] received ~p~n", [Msg])
    after
        % this will trigger if no messages arrived in 100ms
        100000 ->
            io:format("timeout!~n")
    end,
    io:format("main pid done!~n").