%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 四月 2019 19:48
%%%-------------------------------------------------------------------
-module(hi_sup).
-author("Administrator").

%% API
-export([start_link/1, start_child/0, init/1]).

-define(SERVER, ?MODULE).

start_link(Port) ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, [Port]).

start_child() ->
	supervisor:start_link(?SERVER, []).

init([Port]) ->
	Server = {hi_server, {hi_server, start_link, [Port]},
		temporary, brutal_kill, worker, [hi_server]
	},
	Children = [Server],
	%% 一对一和简易一对一的区别
	RestartStrategy = {one_for_one, 0, 1},
	{ok, {RestartStrategy, Children}}.