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
     uniform_s/2,
     jump/1
 ]).

-export_type([
        state/0,
        uint58/0
    ]).

%% @type uint58(). 58bit unsigned integer type.

-type uint58() :: 0..16#03ffffffffffffff.

%% @type state(). Internal state data type for exsplus116.
%% Internally represented as an [S0|S1] improper list,
%% of the 116bit seed.

-type state() :: nonempty_improper_list(uint58(), uint58()).

-define(UINT58MASK, 16#03ffffffffffffff).

%% @doc Generate 58bit unsigned integer from the xorshift116plus internal
%% state and compute next state. Has no side effects.

-spec next(state()) -> {uint58(), state()}.

next([S1|S0]) ->
    %% Note: members s0 and s1 are swapped here
    S11 = (S1 bxor (S1 bsl 24)) band ?UINT58MASK,
    S12 = S11 bxor S0 bxor (S11 bsr 11) bxor (S0 bsr 41),
    {(S0 + S12) band ?UINT58MASK, [S0|S12]}.

-spec seed0() -> state().

%% @doc Set the default seed value to xorshift116plus state
%% in the process directory (Compatible with random:seed0/0).

seed0() -> [287716055029699555|144656421928717457].

%% @doc Set the default seed value to xorshift116plus state
%% in the process directory %% (Compatible with random:seed/1).

-spec seed() -> state().

seed() ->
    case seed_put(seed0()) of
        undefined -> seed0();
        [_S0|_S1] = R -> R
    end.

%% @doc Put the seed, or internal state, into the process dictionary.

-spec seed_put(state()) -> 'undefined' | state().

seed_put(R) ->
    put(exsplus116_seed, R).

%% @doc Set the seed value to xorshift116plus state in the process directory.
%% with the given three-element tuple of unsigned 32-bit integers
%% (Compatible with random:seed/1).

-spec seed({integer(), integer(), integer()}) -> 'undefined' | state().

seed({A1, A2, A3}) ->
    seed(A1, A2, A3).

%% @doc Set the seed value to xorshift116plus state in the process directory
%% with the given three unsigned 32-bit integer arguments
%% (Compatible with random:seed/3).
%% Multiplicands here: three 32-bit primes

-spec seed(integer(), integer(), integer()) -> 'undefined' | state().

seed(A1, A2, A3) ->
    {_, R1} = next(
               [(((A1 * 4294967197) + 1) band ?UINT58MASK) |
                   (((A2 * 4294967231) + 1) band ?UINT58MASK)]),
    {_, R2} = next(
               [(((A3 * 4294967279) + 1) band ?UINT58MASK) |
                   tl(R1)]),
    seed_put(R2).

%% @doc Generate float from
%% given xorshift116plus internal state.
%% (Note: 0.0 &lt; result &lt; 1.0)
%% (Compatible with random:uniform_s/1)

-spec uniform_s(state()) -> {float(), state()}.

uniform_s(R0) ->
    {I, R1} = next(R0),
    {I / (?UINT58MASK + 1), R1}.

-spec uniform() -> float().

%% @doc Generate float
%% given xorshift116plus internal state
%% in the process dictionary.
%% (Note: 0.0 =&lt; result &lt; 1.0)
%% (Compatible with random:uniform/1)

uniform() ->
    R = case get(exsplus116_seed) of
        undefined -> seed0();
        _R -> _R
    end,
    {V, R2} = uniform_s(R),
    put(exsplus116_seed, R2),
    V.

%% @doc Generate integer from given xorshift116plus internal state.
%% (Note: 0 =&lt; result &lt; MAX (given positive integer))
-spec uniform_s(pos_integer(), state()) -> {pos_integer(), state()}.

uniform_s(Max, R) when is_integer(Max), Max >= 1 ->
    {V, R1} = next(R),
    {(V rem Max) + 1, R1}.

%% @doc Generate integer from the given xorshift116plus internal state
%% in the process dictionary.
%% (Note: 1 =&lt; result =&lt; N (given positive integer))
%% (compatible with random:uniform/1)

-spec uniform(pos_integer()) -> pos_integer().

uniform(N) when is_integer(N), N >= 1 ->
    R = case get(exsplus116_seed) of
        undefined -> seed0();
        _R -> _R
    end,
    {V, R1} = uniform_s(N, R),
    put(exsplus116_seed, R1),
    V.

%% @doc This is the jump function for the generator. It is equivalent
%% to 2^64 calls to next(); it can be used to generate 2^52
%% non-overlapping subsequences for parallel computations.

-define(JUMPCONST, 16#000d174a83e17de2302f8ea6bc32c797).
-define(JUMPLEN, 116).

-spec jump(state()) -> state().

jump(S) ->
    jump(S, [0|0], ?JUMPCONST, ?JUMPLEN).

-spec jump(state(), state(), pos_integer(), pos_integer()) -> state().

jump(_, AS, _, 0) -> AS;
jump(S, [AS0|AS1], J, N) ->
    {_, NS} = next(S),
    case (J band 1) of
        1 ->
            [S0|S1] = S,
            jump(NS, [(AS0 bxor S0)|(AS1 bxor S1)], J bsr 1, N-1);
    
        0 ->
            jump(NS, [AS0|AS1], J bsr 1, N-1)
    end.
