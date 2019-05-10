%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 四月 2019 14:19
%%%-------------------------------------------------------------------
-module(gws_connection_sup).
-author("Administrator").

-behaviour(supervisor).

%% API
-export([start_link/4, init/1]).

%%% API
start_link(CallBack, IP, Port, UserArgs) ->
	{ok, Pid} = supervisor:start_link(?MODULE, [CallBack, IP, Port, UserArgs]),
	start_child(Pid),
	{ok, Pid}.

start_child(Server) ->
	supervisor:start_child(Server, []).

%%% Supervisor callbacks
init([Callback, IP, Port, UserArgs]) ->
	BasicSockOpts = [
		binary,
		{active, false},
		{packet, http_bin},
		{reuseaddr, true}
	],
	SockOpts = case IP of
				   undefined -> BasicSockOpts;
				   _ -> [{ip, IP} | BasicSockOpts]
	           end,
	{ok, LSock} = gen_tcp:listen(Port, SockOpts),
	Server = {ges_server, {gws_server, start_link, [Callback, LSock, UserArgs]}, temporary, brutal_kill, worker, [gws_server]},
	RestartStrategy = {simple_one_for_one, 1000, 3600},
	{ok, RestartStrategy, [Server]}.
