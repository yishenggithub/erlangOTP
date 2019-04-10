%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 四月 2019 18:09
%%%-------------------------------------------------------------------
-module(sc_element).
-author("Administrator").

%% API
-export([start_link/2, create/1, fetch/1, replace/2, delete/1]).

-define(SERVER, ?MODULE).
-define(DEFAULT_LEASE_TIME, (60 * 60 *24)).

-record(state, {value, lease_time, start_time}).

start_link(Value, LeaseTime) ->
    gen_server:start_link(?MODULE, [Value, LeaseTime], []).

create(Value, LeaseTime) ->
    sc_sup:start_child(Value, LeaseTime).

create(Value) ->
    create(Value, ?DEFAULT_LEASE_TIME).

fetch(Pid) ->
    gen_server:call(Pid, fetch).

replace(Pid, Value) ->
    gen_server:cast(Pid, {replace, Value}).

delete(Pid) ->
    gen_server:cast(Pid, delete).

init([Value, LeaseTime]) ->

