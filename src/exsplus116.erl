%% @author Kenji Rikitake <kenji.rikitake@acm.org>
%% @copyright 2014 Kenji Rikitake
%% @doc Xorshift116plus for Erlang
%% @end
%% (MIT License)
%%
%% Copyright (c) 2014, 2015 Kenji Rikitake. All rights reserved.
%%
%% Permission is hereby granted, free of charge, to any person obtaining a copy of
%% this software and associated documentation files (the "Software"), to deal in
%% the Software without restriction, including without limitation the rights to
%% use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
%% of the Software, and to permit persons to whom the Software is furnished to do
%% so, subject to the following conditions:
%%
%% The above copyright notice and this permission notice shall be included in all
%% copies or substantial portions of the Software.
%%
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%% SOFTWARE.
%%

-module(exsplus116).

-export([
     next/1,
     seed0/0,
     seed/0,
     seed/1,
     seed/3,
     uniform/0,
     uniform/1,
     uniform_s/1,
     uniform_s/2
 ]).

-export_type([
        state/0,
        uint58/0
    ]).


-include("exsplus116.hrl").


%% @doc Generate 58bit unsigned integer from the xorshift116plus internal
%% state and compute next state. Has no side effects.

-spec next(state()) -> {uint58(), state()}.

next(?state(S1, S0)) ->
    %% Note: members s0 and s1 are swapped here
    S11 = (S1 bxor (S1 bsl 24)) band ?UINT58MASK,
    S12 = S11 bxor S0 bxor (S11 bsr 11) bxor (S0 bsr 41),
    {(S0 + S12) band ?UINT58MASK, ?state(S0, S12)}.


%% @doc Set the default seed value to xorshift116plus state in the process
%% directory. (Compatible with @{link random:seed0/0}.)

-spec seed0() -> state().

seed0() ->
    ?state(287716055029699555, 144656421928717457).


%% @doc Set the default seed value to xorshift116plus state in the process
%% directory. (Compatible with {@link random:seed/1}.)

-spec seed() -> state().

seed() ->
    case seed_put(seed0()) of
        undefined -> seed0();
        ?state(_S0, _S1) = R -> R
    end.


%% @doc Put the seed, or internal state, into the process dictionary.

-spec seed_put(state()) -> 'undefined' | state().

seed_put(R) ->
    put(exsplus116_seed, R).


%% @doc Set the seed value to xorshift116plus state in the process directory
%% with the given three-element tuple of unsigned 32-bit integers.
%% (Compatible with {@link random:seed/1}.)

-spec seed({integer(), integer(), integer()}) -> 'undefined' | state().

seed({A1, A2, A3}) ->
    seed(A1, A2, A3).


%% @doc Set the seed value to xorshift116plus state in the process directory
%% with the given three unsigned 32-bit integer arguments. (Compatible with
%% {@link random:seed/3}.) Multiplicands here: three 32-bit primes.

-spec seed(integer(), integer(), integer()) -> 'undefined' | state().

seed(A1, A2, A3) ->
    {_, ?state(_S0, S1)} =
        next(?state((((A1 * 4294967197) + 1) band ?UINT58MASK),
                    (((A2 * 4294967231) + 1) band ?UINT58MASK))),
    {_, R2} =
        next(?state((((A3 * 4294967279) + 1) band ?UINT58MASK),
                    S1)),
    seed_put(R2).


%% @doc Generate float from given xorshift116plus internal state. (Note:
%% `0.0 < Result < 1.0'.) (Compatible with {@link random:uniform_s/1}.)

-spec uniform_s(state()) -> {Result::float(), state()}.

uniform_s(R0) ->
    {I, R1} = next(R0),
    {I / (?UINT58MASK + 1), R1}.


%% @doc Generate float given xorshift116plus internal state in the process
%% dictionary. (Note: `0.0 =< Result < 1.0'.) (Compatible with {@link
%% random:uniform/1}.)

-spec uniform() -> Result::float().

uniform() ->
    R = case get(exsplus116_seed) of
        undefined -> seed0();
        _R -> _R
    end,
    {V, R2} = uniform_s(R),
    put(exsplus116_seed, R2),
    V.


%% @doc Generate integer from given xorshift116plus internal state.
%% (Note: `0 =< Result < MAX' (given positive integer))

-spec uniform_s(pos_integer(), state()) -> {Result::pos_integer(), state()}.

uniform_s(Max, R) when is_integer(Max), Max >= 1 ->
    {V, R1} = next(R),
    {(V rem Max) + 1, R1}.


%% @doc Generate integer from the given xorshift116plus internal state in
%% the process dictionary. (Note: `1 =< Result =< N' (given positive
%% integer).) (Compatible with {@link random:uniform/1}.)

-spec uniform(pos_integer()) -> Result::pos_integer().

uniform(N) when is_integer(N), N >= 1 ->
    R = case get(exsplus116_seed) of
        undefined -> seed0();
        _R -> _R
    end,
    {V, R1} = uniform_s(N, R),
    put(exsplus116_seed, R1),
    V.
