-module(api_item_handler).

-export([init/2]).

init(Req, State) ->
  #{method := Method} = Req,
  erlang:display("METHOD"),
  erlang:display(Method),
  case Method of 
		<<"GET">> -> get(Req, State);
		<<"PATCH">> -> patch(Req, State);
		<<"DELETE">> -> delete(Req, State);
    <<"OPTIONS">> -> options(Req,State);
		_ -> {ok, cowboy_req:reply(406, #{}, <<"Unsupported method">>, Req), State}
	end.
get(Req,State) ->
  #{bindings := #{todo_id := TodoId}} = Req,
  Get = todo_manager:get_one(uuid:to_binary(binary_to_list(TodoId))),
  try
      {ok,Todo} = Get,
      api_utils:send_json(
        Req,
        State,
        todo_utils:rec2json(
            Todo,
            Req
         )
       )
  catch
      _:Error ->
          {
              ok,
              cowboy_req:reply(
                  404,
                  Req
              ),
              State
        }
    end.
patch(Req,State) ->
  #{bindings := #{todo_id := TodoId}} = Req,
  {ok,Body,_} = cowboy_req:read_body(Req),


  try
      {ok,Todo} = todo_manager:get_one(uuid:to_binary(binary_to_list(TodoId))),

      Update = todo_manager:write(
          todo_utils:map2rec(
              maps:merge(
                  todo_utils:rec2map(Todo),
                  jsone:decode(Body)
              )
          )
      ),
     {ok, NewTodo} = Update,

      api_utils:send_json(
          Req, State, todo_utils:rec2json(NewTodo, Req)
      )
  catch
      _:Error ->
          {
              ok,
              cowboy_req:reply(
                  404,
                  #{},
                  Req
              ),
              State
        }
  end.
delete(Req,State) ->
    #{bindings := #{todo_id := TodoId}} = Req,
    todo_manager:delete_one(uuid:to_binary(binary_to_list(TodoId))),
    {
      ok,
      cowboy_req:reply(
        200,
        Req
      ),
      State
    }.
options(Req,State) ->
  {
    ok,
    cowboy_req:reply(
      200,
      #{
          <<"Allow">> => <<"OPTIONS, PATCH, GET">>
      },
      Req
    ),
    State
  }.
