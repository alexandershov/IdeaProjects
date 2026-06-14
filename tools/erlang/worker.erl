-module(worker).
% gen_server gives you a server loop
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2]).

start_link() ->
    % register worker
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    io:format("worker started!~n"),
    {ok, #{}}.

handle_call({divide, X, Y}, _From, State) ->
    % handle sync request
    if
        Y == 0 ->
            io:format("division by zero!~n"),
            exit(division_by_zero);
        true ->
            io:format("handle call!~n"),
            {reply, X / Y, State}
    end.

handle_cast(_Msg, State) ->
    % handle async requests
    {noreply, State}.