-module(todo_utils).

-export([json2rec/1, rec2json/2,list2json/2,rec2map/1,map2rec/1]).

-include("todo.hrl").

json2rec(String) ->
    map2rec(jsone:decode(String)).
rec2map(Rec) ->
  #{
    <<"title">> => Rec#todo.title,
    <<"text">> => Rec#todo.text,
    <<"completed">> => Rec#todo.completed,
    <<"id">> => Rec#todo.id,
    <<"order">> => Rec#todo.order
  }.

map2rec(Map) ->
    Id = case maps:is_key(<<"id">>, Map) of
        true -> maps:get(<<"id">>, Map);
        _ -> uuid:uuid1()
    end,
    #todo{
      id=Id,
      title=maps:get(<<"title">>, Map),
      completed=maps:get(<<"completed">>, Map, false),
      order=maps:get(<<"order">>, Map, null),
      text=maps:get(<<"text">>, Map,<<"">>)
    }.
rec2json_map(Rec,Req) ->
    stringify_map_id(
        add_url_to_map(
            rec2map(Rec),
            Req
        )
    ).
rec2json(Rec,Req) ->
    jsone:encode(rec2json_map(Rec,Req)).

list2json(List,Req) ->
   jsone:encode(
        [rec2json_map(Map, Req) || Map <- List],
        [native_forward_slash]
    ).

build_url(Req,Id) ->
    #{port := Port0, host := Host, ref := Protocol0} = Req,
    Protocol = os:getenv("FORCE_PROTOCOL", atom_to_list(Protocol0)),
    Port = os:getenv("FORCE_PORT", integer_to_list(Port0)),
    PortString = case (((Port == "80") and (Protocol == "http")) or ((Port == "443") and (Protocol == "https"))) of
      true -> "";
      false -> ":" ++ Port
    end,
    list_to_binary(
        Protocol ++
        "://" ++
        binary_to_list(Host) ++
        PortString ++
        "/" ++
        Id
    ).
add_url_to_map(Map,Req) ->
    maps:put(
        <<"url">>,
        build_url(
            Req,
            uuid:to_string(maps:get(<<"id">>,Map))
        ),
        Map
    ).
stringify_map_id(Map) ->
    maps:put(
        <<"id">>,
        list_to_binary(uuid:to_string(maps:get(<<"id">>, Map))),
        Map
    ).
