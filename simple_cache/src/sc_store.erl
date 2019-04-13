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

init() ->

  ets:new(?TABLE_ID, [public, named_table]),
  ok.

insert(Key, Pid) ->
  ets:insert(?TABLE_ID, {Key, Pid}).

lookup(Key) ->
  case ets:lookup(?TABLE_ID, Key) of
    [{Key, Pid}] -> {ok, Pid};
    [] -> {error, not_found}
  end.

delete(Pid) ->
  ets:match_delete(?TABLE_ID, {'_', Pid}).

