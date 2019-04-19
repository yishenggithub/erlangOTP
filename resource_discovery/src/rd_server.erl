%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. 四月 2019 15:26
%%%-------------------------------------------------------------------
-module(rd_server).
-author("Administrator").

%% API
-export([handle_call/3, handle_cast/2, init/1, start_link/0, code_change/3, terminate/2, handle_info/2]).
-export([add_target_resource_type/1, add_local_resource/2, fetch_resources/1, trade_resources/0]).

-define(SERVER, ?MODULE).

-record(state, {
	target_resource_types,
	local_resource_tuples,
	found_resource_tuples
}).

%% API

start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

add_target_resource_type(Type) ->
	gen_server:cast(?SERVER, {add_target_resource_type, Type}).

add_local_resource(Type, Resource) ->
	gen_server:cast(?SERVER, {add_local_resource, {Type, Resource}}).

fetch_resources(Type) ->
	gen_server:call(?SERVER, {fetch_resources, Type}).

trade_resources() ->
	gen_server:cast(?SERVER, trade_resources).

%% Callbacks

init([]) ->
	{ok, #state{
		target_resource_types = [],
		local_resource_tuples = dict:new(),
		found_resource_tuples = dict:new()
	}}.

handle_call({fetch_resources, Type}, _From, State) ->
	{reply, dict:find(Type, State#state.found_resource_tuples), State}.

handle_cast({add_target_resource_type, Type}, State) ->
	TargetTypes = State#state.target_resource_types,
	NewTargetTypes = [Type | lists:delete(Type, TargetTypes)],
	{noreply, State#state{target_resource_types = NewTargetTypes}};

handle_cast({add_local_resource, {Type, Resource}}, State) ->
	ResourceTuples = State#state.local_resource_tuples,
	NewResourceTuples = add_resource(Type, Resource, ResourceTuples),
	{noreply, State#state{local_resource_tuples = NewResourceTuples}};

handle_cast(trade_resources, State) ->
	ResourceTuples = State#state.local_resource_tuples,
	AllNodes = [node() | nodes()],
	lists:foreach(
		fun(Node) ->
			gen_server:cast({?SERVER, Node},
				{trade_resources, {node(), ResourceTuples}})
		end,
		AllNodes),
	{noreply, State};

handle_cast({trade_resources, {ReplyTo, Remote}},
	#state{local_resource_tuples = Locals,
		target_resource_types = TargetTypes,
		found_resource_tuples = OldFound} = State
) ->
	FilteredRemotes = resources_for_types(TargetTypes, Remote),
	NewFound = add_resources(FilteredRemotes, OldFound),
	case ReplyTo of
		norely ->
			ok;
		_ ->
			gen_server:cast({?SERVER, ReplyTo}, {trade_resources, {norely, Locals}})
	end,
	{noreply, State#state{found_resource_tuples = NewFound}}.

handle_info(ok = _Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%% Utilities

add_resources([{Type, Resource}|T], Dict) ->
	add_resources(T, add_resource(Type, Resource, Dict));
add_resources([], Dict) ->
	Dict.
resources_for_types(Types, Dict) ->
	Fun =
		fun(Type, Acc) ->
			case dict:find(Type, Dict) of
				{ok, List} ->
					[{Type, Instance} || Instance <- List] ++ Acc;
				error ->
					Acc
			end
		end,
	lists:foldl(Fun, [], Types).

add_resource(Type, Resource, Dict) ->
	case dict:find(Type, Dict) of
		{ok, ResourceList} ->
			NewList = [Resource | lists:delete(Resource, ResourceList)],
			dict:store(Type, NewList, Dict);
		error ->
			dict:store(Type, [Resource], Dict)
	end.