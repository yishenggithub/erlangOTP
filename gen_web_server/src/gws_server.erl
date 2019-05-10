%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 四月 2019 14:19
%%%-------------------------------------------------------------------
-module(gws_server).
-author("Administrator").

%% API
-export([start_link/3, init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).

-record(state, {lsock, socket, request_line, headers = [],
	body = <<>>, content_remaining = 0,
	callback, user_data, parent}).

%%% API
start_link(CallBack, LSock, UserArgs) ->
	gen_server:start_link(?MODULE, [CallBack, LSock, UserArgs, self()], []).

%% gen_server callback
init([CallBack, LSock, UserArgs, Parent]) ->
	{ok, UserData} = CallBack:init(UserArgs),
	State = #state{lsock = LSock, callback = CallBack, user_data = UserData, parent = Parent},
	{ok, State, 0}.

handle_call(_Request, _From, State) ->
	{reply, ok, State}.

handle_cast(_Request, State) ->
	{noreply, State}.

handle_info({http, _Sock, {http_request, _, _, _} = Request}, State) ->
	inet:setopts(State#state.socket, [{active, once}]),
	{noreply, State#state{request_line = Request}};
handle_info({http, _Sock, {http_header, _, Name, _, Value}}, State) ->
	inet:setopts(State#state.socket, [{active, once}]),
	{noreply, header(Name, Value, State)};
handle_info({http, _Sock, http_eoh}, #state{content_remaining = 0} = State) ->
	{stop, normal, handle_http_request(State)};
handle_info({http, _Sock, http_eoh}, State) ->
	inet:setopts(State#state.socket, [{active, once}, {packet, raw}]),
	{noreply, State};
handle_info({tcp, _Sock, Data}, State) when is_binary(Data) ->
	ContentRem = State#state.content_remaining - byte_size(Data),
	Body = list_to_binary([State#state.body, Data]),
	NewState = State#state{body = Body, content_remaining = ContentRem},
	if ContentRem > 0 ->
		    inet:setopts(State#state.socket, [{active, once}]),
			{noreply, NewState};
		true ->
			{stop, normal, handle_http_request(NewState)}
	end;
handle_info({tcp_closed, _Sock}, State) ->
	{stop, normal, State};
handle_info(timeout, #state{lsock = LSock, parent = Parent} = State) ->
	{ok, Socket} = gen_tcp:accept(LSock),
	gws_connection_sup:start_child(Parent),
	inet:setopts(Socket, [{active, once}]),
	{noreply, State#state{socket = Socket}}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%% Internal Functions

header('Content_Length' = Name, Value, State) ->
	ContentLength = list_to_integer(binary_to_list(Value)),
	State#state{content_remaining = ContentLength, headers = [{Name, Value} | State#state.headers]};
header(<<"Expect">> = Name, <<"100-continue">> = Value, State) ->
	gen_tcp:send(State#state.socket, gen_web_server:http_reply(100)),
	State#state{headers = [{Name, Value} | State#state.headers]};
header(Name, Value, State) ->
	State#state{headers = [{Name, Value} | State#state.headers]}.

handle_http_request(#state{callback = CallBack,
	request_line = Request,
	headers = Headers,
	body = Body,
	user_data = UserData} = State) ->
	{http_request, Method, _, _} = Request,
	Reply = dispatch(Method, Request, Headers, Body, CallBack, UserData),
	gen_tcp:send(State#state.socket, Reply),
	State.
dispatch('GET', Request, Headers, _Body, CallBack, UserData) ->
	CallBack:get(Request, Headers, UserData);
dispatch('DELETE', Request, Headers, _Body, CallBack, UserData) ->
	CallBack:delete(Request, Headers, UserData);
dispatch('HEAD', Request, Headers, _Body, CallBack, UserData) ->
	CallBack:head(Request, Headers, UserData);

dispatch('POST', Request, Headers, Body, CallBack, UserData) ->
	CallBack:post(Request, Headers, Body, UserData);
dispatch('PUT', Request, Headers, Body, CallBack, UserData) ->
	CallBack:put(Request, Headers, Body, UserData);
dispatch('TRACE', Request, Headers, Body, CallBack, UserData) ->
	CallBack:trace(Request, Headers, Body, UserData);
dispatch('OPTIONS', Request, Headers, Body, CallBack, UserData) ->
	CallBack:options(Request, Headers, Body, UserData);
dispatch(_Other, Request, Headers, Body, CallBack, UserData) ->
	CallBack:other_methods(Request, Headers, Body, UserData).


