#!/usr/bin/env escript
%% -*- erlang -*-
%%! -pa ./ebin

%% Note: execute from the root path

-define(TARGET_MODULE, exsplus116).

loop(_S, 0) -> ok;
loop(S, N) ->
    {V, NS} = ?TARGET_MODULE:next(?TARGET_MODULE:jump(S)),
    [NS0|NS1] = NS,
    io:format("next = ~p s[0] = ~p s[1] = ~p~n", [V, NS0, NS1]),
    loop(NS, N - 1).

main(_) ->

    code:load_file(?TARGET_MODULE),
    IS = [287716055029699555|144656421928717457],
    [IS0|IS1] = IS,
    io:format("s[0] = ~p s[1] = ~p~n", [IS0, IS1]),
    {V, S} = ?TARGET_MODULE:next(IS),
    [S0|S1] = S,
    io:format("next = ~p s[0] = ~p s[1] = ~p~n", [V, S0, S1]),
    ok = loop(S, 99).
