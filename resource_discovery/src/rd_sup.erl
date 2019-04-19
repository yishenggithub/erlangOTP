%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 四月 2019 15:26
%%%-------------------------------------------------------------------
-module(rd_sup).
-author("Administrator").

%% API
-export([start_link/0, init/1]).

-define(SERVER, ?MODULE).

start_link() ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
	Server = {rd_server, {rd_server, start_link, []},
		permanent, 2000, worker, [rd_server]
		},
	Children = [Server],
	RestartStrategy = {one_for_one, 0, 1},
	{ok, {RestartStrategy, Children}}.