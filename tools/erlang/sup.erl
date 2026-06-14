-module(sup).
% behaviour supervisor is essentially declaration "I'll implement supervisor interface"
% supervisor interface is init/1
-behaviour(supervisor).

-export([start_link/0, init/1, start/0]).

start_link() ->
    % register supervisor
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


start() ->
    supervisor:start({local, ?MODULE}, ?MODULE, []).

init([]) ->
    SupFlags = #{
        % restart only the crashed child
        strategy => one_for_one,
        % at most 5 restarts, after that supervisor crashes
        intensity => 5,
        % withing 10 seconds
        period => 10
    },

    ChildSpecs = [
        #{
            id => worker,
            % module, function, arguments
            start => {worker, start_link, []},
            % always restart, even after "regular" exit
            restart => permanent,
            % wait for 5s - graceful shutdown
            shutdown => 5000,
            type => worker,
            % used for hot reloads
            modules => [worker]
        }
    ],

    {ok, {SupFlags, ChildSpecs}}.