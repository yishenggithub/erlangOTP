%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. 四月 2019 19:30
%%%-------------------------------------------------------------------
-module(resource_discovery).
-author("Administrator").

%% API
-export([
	add_target_resource_type/1,
	fetch_resources/1,
	trade_resources/0,
	add_local_resource/2]).

add_target_resource_type(Type) ->
	rd_server:add_target_resource_type(Type).
%%	gen_server:cast(?SERVER, {add_target_resource_type, Type}).

add_local_resource(Type, Instance) ->
	rd_server:add_local_resource(Type, Instance).
%%	gen_server:cast(?SERVER, {add_local-resource, {Type, Instance}}).

fetch_resources(Type) ->
	rd_server:fetch_resources(Type).
%%	gen_server:call(?SERVER, {fetch_resources, Type}).

trade_resources() ->
	rd_server:trade_resources().
%%	gen_server:cast(?SERVER, trade_resource).






