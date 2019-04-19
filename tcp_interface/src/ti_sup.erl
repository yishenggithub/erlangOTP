%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 四月 2019 12:03
%%%-------------------------------------------------------------------
-module(ti_sup).
-author("Administrator").

-behaviour(supervisor).

%% API
-export([start_link/1, start_child/0, init/1]).

-define(SERVER, ?MODULE).

start_link(LSock) ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, [LSock]).

start_child() ->
	supervisor:start_link(?SERVER, []).

init([LSock]) ->
	Server = {ti_server, {ti_server, start_link, [LSock]},
		temporary, brutal_kill, worker, [ti_server]
		},
	Children = [Server],
	RestartStrategy = {simple_one_for_one, 0, 1},
	{ok, {RestartStrategy, Children}}.

