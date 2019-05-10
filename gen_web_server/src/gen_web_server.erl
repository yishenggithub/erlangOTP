%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 四月 2019 14:18
%%%-------------------------------------------------------------------
-module(gen_web_server).
-author("Administrator").

%% API
-export([behaviour_info/1, start_link/3, start_link/4, http_reply/3, http_reply/1, http_reply/2, headers/1, response/1]).

behaviour_info(callbacks) ->
	[
		{init, 1},
		{head, 3},
		{get, 3},
		{delete, 3},
		{options, 4},
		{post, 4},
		{put, 4},
		{trace, 4},
		{other_methods, 4}
	];
behaviour_info(_Other) ->
	undefined.

%%% API
start_link(Callback, Port, UserArgs) ->
	start_link(Callback, undefined, Port, UserArgs).

start_link(CallBack, IP, Port, UserArgs) ->
	gws_connection_sup:start_link(CallBack, IP, Port, UserArgs).

http_reply(Code, Headers, Body) ->
	ContentBytes = iolist_to_binary(Body),
	Length = byte_size(ContentBytes),
	[io_lib:format("HTTP/1.1 ~s\r\n~sContent-Length: ~w\r\n\r\n",
		[response(Code), headers(Headers), Length]), ContentBytes].

http_reply(Code) ->
	http_reply(Code, <<>>).

http_reply(Code, Body) ->
	http_reply(Code, [{"Content-Type", "text/html"}], Body).

%%% Internal function

headers([{Header, Text} | Hs]) ->
	[io_lib:format("~s: ~s\r\n", [Header, Text]) | headers(Hs)];
headers([]) ->
	[].

response(100) -> "100 Continue";
response(200) -> "200 OK";
response(404) -> "404 Not Found";
response(501) -> "501 Not Implemented";
response(Code) -> integer_to_list(Code).

