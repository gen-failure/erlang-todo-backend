-module(api_utils).

-export([send_json/3, send_json/4]).

send_json(Req, State, Json) ->
     send_json(Req, State, Json, 200).

send_json(Req, State, Json, Status) ->
    {
        ok,
        cowboy_req:reply(
          Status,
          #{
            <<"content-type">> => <<"aplication/json">>
          },
          Json,
          Req
        ),
        State
    }.
extract_todo_id(TodoId) ->
  uuid:to_binary(binary_to_list(TodoId)).
