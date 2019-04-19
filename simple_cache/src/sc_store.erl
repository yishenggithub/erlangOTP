%%%-------------------------------------------------------------------
%%% @author easom
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. 四月 2019 0:36
%%%-------------------------------------------------------------------
-module(sc_store).
-author("easom").

%% API
-export([delete/1, lookup/1, insert/2, init/0]).

-define(TABLE_ID, ?MODULE).
-define(WAIT_FOR_TABLES, 5000).

-record(key_to_pid, {key, pid}).

init() ->
%%  /////1
%%  ets:new(?TABLE_ID, [public, named_table]),
%%  ok.
%%  /////2
%%  mnesia:start(),
%%  mnesia:create_table(key_to_pid,
%%    [{index, [pid]},
%%      {attributes, record_info(fields, key_to_pid)}]
%%    ).
%/////3
  mnesia:stop(),
  mnesia:delete_schema([node()]),
  mnesia:start(),
  {ok, CacheNodes} = resource_discovery:fetch_resources(simple_cache),
  dynamic_db_init(lists:delete(node(), CacheNodes)).

insert(Key, Pid) ->
  ets:insert(?TABLE_ID, {Key, Pid}).

lookup(Key) ->
%%  case ets:lookup(?TABLE_ID, Key) of
%%    [{Key, Pid}] -> {ok, Pid};
%%    [] -> {error, not_found}
%%  end.
  case mnesia:dirty_read(key_to_pid, Key) of
    [{key_to_pid, Key, Pid}] ->
      case is_pid_alive(Pid) of
        true -> {ok, Pid};
        false -> {error, not_found}
      end;
    [] ->{error, not_found}
  end.

delete(Pid) ->
%%  ets:match_delete(?TABLE_ID, {'_', Pid}).
  case mnesia:dirty_index_read(key_to_pid, Pid, #key_to_pid.pid) of
    [#key_to_pid{} = Record] ->
      mnesia:dirty_delete_object(Record);
    _ ->
      ok
  end.

dynamic_db_init([]) ->
  mnesia:create_table(key_to_pid,
    [{index, [pid]},
      {attributtes, record_info(fields, key_to_pid)}]);
dynamic_db_init(CacheNodes) ->
  add_extra_nodes(CacheNodes).

add_extra_nodes([Node|T]) ->
  case mnesia:change_config(extra_db_nodes, [Node]) of
    {ok, [Node]} ->
      mnesia:add_table_copy(schema, node(), ram_copies),
      mnesia:add_table_copy(key_to_pid, node(), ram_copies),
      Tables =mnesia:system_info(tables),
      mnesia:wait_for_tables(Tables, ?WAIT_FOR_TABLES);
    _ ->
      add_extra_nodes(T)
  end.

is_pid_alive(Pid) when node(Pid) =:= node() ->
  is_pid_alive(Pid);

is_pid_alive(Pid) ->
  case lists:member(node(Pid), nodes()) of
    false ->
      false;
    true ->
      case rpc:call(node(Pid), erlang, is_process_alive, [Pid]) of
        true ->
          true;
        false ->
          false;
        {badrpc, _Reason} ->
          false
      end
  end.