#!/usr/bin/env escript
%% -*- erlang -*-
%%! -pa ./ebin

%% Note: execute from the root path

-define(TARGET_MODULE, exsplus116).
-define(TEST_MODULE, exsplus116_speed).

main(_) ->

    code:load_file(?TARGET_MODULE),
    code:load_file(?TEST_MODULE),

    ?TEST_MODULE:test_speed(),
    ?TEST_MODULE:test_speed(),
    ?TEST_MODULE:test_speed(),
    ?TEST_MODULE:test_speed(),
    ?TEST_MODULE:test_speed(),
    io:format("end of testspeed.escript~n"),
    ok.


