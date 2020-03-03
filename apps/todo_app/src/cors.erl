-module(cors).
-behaviour(cowboy_middleware).

-export([execute/2]).

execute(Req0, Env) -> 
    Req1 = cowboy_req:set_resp_header(<<"access-control-allow-methods">>, <<"GET, POST, PATCH, DELETE">>, Req0),
    Req2 = cowboy_req:set_resp_header(<<"access-control-allow-origin">>, <<"*">>, Req1),
    Req3 = cowboy_req:set_resp_header(<<"access-control-allow-headers">>, <<"content-type">>, Req2),
    {ok, Req3, Env}.
