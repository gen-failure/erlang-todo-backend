-module(todo_manager).

-export([init/0,get_all/0,delete_all/0,get_one/1,write/1,delete_one/1]).

-include("todo.hrl").

init() -> 
  mnesia:start(),
  Res = mnesia:create_table(todo,[{attributes,record_info(fields,todo)},{disc_copies, nodes()}]),
  erlang:display(Res).
write(Todo) ->
    true = uuid:is_valid(Todo#todo.id),
    T = fun() ->
        mnesia:write(Todo)
    end,
    {atomic,ok} = mnesia:transaction(T),
    get_one(Todo#todo.id).
get_all() ->
  F = fun() -> mnesia:select(todo,[{'_',[],['$_']}]) end,
  mnesia:activity(transaction, F).
get_one(Id) ->
    R = fun() ->
        mnesia:read(todo,Id,read)
    end,
    {atomic,Result} = mnesia:transaction(R),
    if
        (length(Result) == 1) -> {ok, lists:nth(1,Result)};
        (true) -> {not_found}
    end.
delete_all() ->
    mnesia:clear_table(todo).
delete_one(Id) ->
    R = fun() ->
        mnesia:delete(todo,Id, write)
    end,
    erlang:display(mnesia:transaction(R)),
    {ok}.
    
