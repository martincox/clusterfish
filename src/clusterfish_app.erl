%%%-------------------------------------------------------------------
%% @doc clusterfish public API
%% @end
%%%-------------------------------------------------------------------

-module(clusterfish_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    clusterfish_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================