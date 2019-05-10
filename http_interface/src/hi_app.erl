%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. 四月 2019 19:48
%%%-------------------------------------------------------------------
-module(hi_app).
-author("Administrator").

%% API
-export([stop/1, start/2]).

-define(DEFAULT_PORT, 1156).

start(_StartType, _StartArgs) ->
	Port = case application:get_env(http_interface, port) of
		       {ok, P} -> P;
		       undefined -> ?DEFAULT_PORT
	       end,
	case hi_sup:start_link(Port) of
		{ok, Pid} ->
			{ok, Pid};
		Other ->
			{error, Other}
	end.

stop(_State) ->
	ok.