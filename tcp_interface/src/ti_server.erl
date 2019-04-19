%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 19. 四月 2019 12:03
%%%-------------------------------------------------------------------
-module(ti_server).
-author("Administrator").

%% API
-export([code_change/3, terminate/2, start_link/1, init/1, handle_call/3, handle_cast/2, handle_info/2]).

-record(state, {lsock}).

start_link(LSock) ->
	gen_server:start_link(?MODULE, [LSock], []).

init([LSock]) ->
	{ok, #state{lsock = LSock}, 0}.

handle_call(Msg, _From, State) ->
	{reply, {ok, Msg}, State}.

handle_cast(stop, State) ->
	{stop, normal, State}.

handle_info({tcp, Socket, RawData}, State) ->
	NewState = handle_data(Socket, RawData, State),
	{noreply, NewState};
handle_info({tcp_closed, _Socket}, State) ->
	{stop, normal, State};
handle_info(timeout, #state{lsock = LSock} = State) ->
	{ok, _Sock} = gen_tcp:accept(LSock),
	ti_sup:start_child(),
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

handle_data(Socket, RawData, State) ->
	gen_tcp:send(Socket, RawData),
	State.
