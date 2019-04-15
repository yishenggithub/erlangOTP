%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 四月 2019 17:08
%%%-------------------------------------------------------------------
-module(sc_event).
-author("Administrator").

%% API
-export([start_link/0, add_handler/2, delete_handler/2, lookup/1, create/2, replace/2, delete/1]).

-define(SERVER, ?MODULE).

start_link() ->
	gen_event:start_link({local, ?SERVER}).

add_handler(Handler, Args) ->
	gen_event:add_handler(?SERVER, Handler, Args).

delete_handler(Handler, Args) ->
	gen_event:delete_handler(?SERVER, Handler, Args).

lookup(Key) ->
	gen_event:notify(?SERVER, {lookup, Key}).

create(Key, Value) ->
	gen_event:notify(?SERVER, {create, {Key, Value}}).

replace(Key, Value) ->
	gen_event:notify(?SERVER, {replace, {Key, Value}}).

delete(Key) ->
	gen_event:notify(?SERVER, {delete, Key}).

