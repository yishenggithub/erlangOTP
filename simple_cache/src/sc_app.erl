%%%-------------------------------------------------------------------
%%% @author Administrator
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. 四月 2019 10:12
%%%-------------------------------------------------------------------
-module(sc_app).
-author("Administrator").

-behaviour(application).

%% API
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    case sc_sup:start_link() of
        {ok, Pid} ->
            {ok, Pid};
        Other ->
            {error, Other}
    end.
stop(_State) ->
    ok.
