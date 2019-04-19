%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 四月 2019 15:26
%%%-------------------------------------------------------------------
-module(rd_app).
-author("Administrator").

%% API
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
	case rd_sup:start_link() of
		{ok, Pid} ->
			{ok, Pid};
		Other ->
			{error, Other}
	end.

stop(_State) ->
	ok.
