-module(tutorial).

% /0 is function arity
-export([main/0, sum/2, adder_loop/0]).

sum(X, Y) ->
    X + Y.

adder_loop() ->
    receive
        % this is pattern matching, add is atom; From, X, Y are variables
        {add, From, X, Y} ->
            io:format("adder: received [~p, ~p, ~p]~n", [From, X, Y]),
            From ! {ok, X + Y},
            % We call ourselves recursively, so this process forever handles messages
            % by calling ourselves with ?MODULE:adder_loop this code is hot reload friendly:
            % connect to a running program: erl -sname debug -setcookie secret -remsh myapp
            % then run c(tutorial) and you'll get hot code reload
            % without ?MODULE we'll continue executing old version of the adder_loop
            ?MODULE:adder_loop()
    end.

main() ->
    % spawn creates a lightweight process, it's not an OS process, it's managed by Erlang VM (called BEAM)
    AdderPid = spawn(fun() -> adder_loop() end),
    % now we can send messages by name, also from other OS processes
    % erl -sname debug -setcookie secret
    % and then {adder, 'myapp@Mac'} ! {add, self(), 10, 20} will send erlang message to this worker!
    % it works cross OS-processes and cross hosts!
    % e.g. here's a log: adder: received [<10877.90.0>, 10, 20]
    register(adder, AdderPid),
    io:format("AdderPid = ~p~n", [AdderPid]),
    spawn(fun Loop() ->
        % ! sends a message to pid, it sends a message asynchronously
        % self() is pid of the current erlang process
        % processes interact by sending messages to each other
        AdderPid ! {add, self(), 3, 2},
        AdderPid ! {add, self(), 6, 7},
        io:format("sent add~n"),
        receive
            Msg ->
                io:format("before~n"),
                io:format("received ~p~n", [Msg]),
                io:format("after~n"),
                timer:sleep(10000),
                Loop()
            % {ok, Result} -> io:format("Result = ~B~n", [Result])
        end
    end),

    receive
        Msg ->
            io:format("[main] received ~p~n", [Msg])
    after
        % this will trigger if no messages arrived in 100000ms
        100000 ->
            io:format("timeout!~n")
    end,
    io:format("main pid done!~n").