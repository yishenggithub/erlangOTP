%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 四月 2019 12:02
%%%-------------------------------------------------------------------
-module(ti_app).
-author("Administrator").

-behaviour(application).

%% API
-export([stop/1, start/2]).

-define(DEFAULT_PORT, 1155).

start(_StartType, _StartArgs) ->
	Port = case application:get_env(tcp_interface, port) of
		       {ok, P} -> P;
		       undefined -> ?DEFAULT_PORT
	       end,
	{ok, LSock} = gen_tcp:listen(Port, [{active, true}]),
	case ti_sup:start_link(LSock) of
		{ok, Pid} ->
			ti_sup:start_child(),
			{ok, Pid};
		Other ->
			{error, Other}
	end.

stop(_State) ->
	ok.