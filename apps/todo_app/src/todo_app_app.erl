%%%-------------------------------------------------------------------
%% @doc todo_app public API
%% @end
%%%-------------------------------------------------------------------

-module(todo_app_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
      todo_manager:init(),
        Dispatch = cowboy_router:compile([
        {'_',
         [
          {"/", api_list_handler, []},
          {"/:todo_id", api_item_handler, []}
         ]
        }
    ]),
    {ok, _} = cowboy:start_clear(
        http,
        [{port, element(1,string:to_integer(os:getenv("PORT", "8080")))}],
        #{
          env => #{dispatch => Dispatch},
          middlewares => [cowboy_router, cors, cowboy_handler]
        }
    ),
    todo_app_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
