-module(api_list_handler).

-include("todo.hrl").

-export([init/2]).

init(Req, State) ->
  #{method := Method} = Req,
  case Method of 
		<<"GET">> -> get(Req, State);
    <<"POST">> -> post(Req, State);
    <<"DELETE">> -> delete(Req, State);
    <<"OPTIONS">> -> options(Req, State);
		_ -> {ok, cowboy_req:reply(500, #{}, <<"Unsupported method">>, Req), State}
	end.

get(Req, State) ->
    api_utils:send_json(
        Req,
        State,
        todo_utils:list2json(
            todo_manager:get_all(),
            Req
        )
    ).
post(Req, State) ->
  {ok,Body,_} = cowboy_req:read_body(Req),
  Todo0 = todo_utils:json2rec(Body),
  {ok, Todo1} = todo_manager:write(Todo0),
  api_utils:send_json(
    Req,
    State,
    todo_utils:rec2json(Todo1, Req),
    201
  ).
delete(Req, State) ->
  todo_manager:delete_all(),
  {
    ok,
    cowboy_req:reply(200,Req),
    State
  }.
options(Req, State) ->
  {
    ok,
    cowboy_req:reply(
      200,
      #{
        <<"Allow">> => <<"OPTIONS, POST, GET">>
      },
      Req
    ),
    State
  }.

