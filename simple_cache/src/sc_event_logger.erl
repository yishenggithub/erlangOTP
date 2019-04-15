%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 四月 2019 18:42
%%%-------------------------------------------------------------------
-module(sc_event_logger).
-author("Administrator").

%% API
-export([handle_event/2, delete_handler/0, add_handler/0]).

add_handler() ->
	sc_event:add_handler(?MODULE, []).

delete_handler() ->
	sc_event:delete_handler(?MODULE, []).

handle_event({create, {Key, Value}}, State) ->
	error_logger:info_msg("create(~w, ~w)~n", [Key, Value]),
	{ok, State};

handle_event({lookup, Key}, State) ->
	error_logger:info_msg("lookup(~w)~n", [Key]),
	{ok, State};

handle_event({delete, Key}, State) ->
	error_logger:info_msg("delete(~w)~n", [Key]),
	{ok, State};

handle_event({replace, {Key, Value}}, State) ->
	error_logger:info_msg("erplace(~w, ~w)~n", [Key, Value]),
	{ok, State}.
