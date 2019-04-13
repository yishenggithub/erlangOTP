%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. 四月 2019 10:12
%%%-------------------------------------------------------------------
-module(sc_store).
-author("Administrator").

%% API
-export([init/0, insert/2, lookup/1]).


-define(TABLE_ID, ?MODULE).

init() ->
	ets:new(?TABLE_ID, [public, name_table]),
	ok.

insert(Key, Pid) ->
	ets:insert(?TABLE_ID, {Key, Pid}).

lookup(Key) ->
	case ets:lookup(?TABLE_ID, Key) of
		[{Key, Pid}] ->{ok, Pid};
		[] -> {error, not_found}
	end.
