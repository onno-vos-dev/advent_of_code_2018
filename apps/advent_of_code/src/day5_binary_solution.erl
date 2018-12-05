%% Disclaimer: I intended to use only binary matching here.
%% Not the prettiest
%% Not the fastest (About 5.5 seconds for part A... Much sadness)
%% But playing with binary strings was fun and educational so screw that :)
-module(day5_binary_solution).

-export([ run/0
        ]).

-spec run() -> [{atom(), integer()}].
run() ->
  Input = input(),
  PolymerA = polymer(Input, <<"">>, 0),
  String = string:to_upper(b2l(Input)),
  UniqChars = [b2l(Char) || {Char, []} <- uniq(list_to_binary(String), dict:new())],
  {_, LengthB} = partb(UniqChars, PolymerA),
  [ {a, length(PolymerA)}
  , {b, LengthB}
  ].

partb(Chars, PolymerA) ->
  partb(Chars, PolymerA, {<<"">>, length(PolymerA)}).

partb([], _PolymerA, Acc) -> Acc;
partb([H|T], PolymerA, {Char, Length}) ->
  Rex = "["++string:to_upper(H) ++ string:to_lower(H)++"]",
  Input = re:replace(PolymerA, Rex, "", [global, {return, binary}]),
  Polymer = polymer(Input, <<"">>, 0),
  Polymer = polymer(Input, <<"">>, 0),
  case length(Polymer) < Length of
    true -> partb(T, PolymerA, {H, length(Polymer)});
    false -> partb(T, PolymerA, {Char, Length})
  end.

uniq(<<>>, Acc) -> dict:to_list(Acc);
uniq(<<A:1/binary>>, Acc) -> dict:to_list(dict:store(A, [], Acc));
uniq(<<A:1/binary,T/binary>>, Acc) ->
  uniq(T, dict:store(A, [], Acc)).

input() ->
  {ok, Bin} = file:read_file(code:priv_dir(advent_of_code) ++ "/day5.txt"),
  list_to_binary(string:trim(binary_to_list(Bin))).

polymer(<<>>, P, _I) -> b2l(P);
polymer(<<A:1/binary>>, P, _I) -> b2l(push(P, A));
polymer(<<A:1,B:1/binary>>, P, _I) when A =:= B -> b2l(push(P, A, B));
polymer(<<A:1,B:1/binary>>, P, _I) when A =/= B ->
  case is_different_polarity(A, B) of
    true ->
      b2l(P);
    false ->
      b2l(push(P, A, B))
  end;
polymer(<<A:1/binary,B:1/binary,T/binary>>, P, I) when A =:= B ->
  polymer(push(B, T), push(P, A), I + 1);
polymer(<<A:1/binary,B:1/binary,T/binary>>, P, I) when A =/= B ->
  case is_different_polarity(A, B) of
    true ->
      {NewP, NewT} = maybe_drop_chars(P, T),
      polymer(NewT, NewP, I + 1);
    false ->
      {NewP, NewA} = maybe_drop_chars(P, A),
      polymer(push(B, T), push(NewP, NewA), I + 1)
  end.

maybe_drop_chars(<<>> = A, B) when is_binary(A) andalso is_binary(B) -> {A, B};
maybe_drop_chars(A, <<>> = B) when is_binary(A) andalso is_binary(B) -> {A, B};
maybe_drop_chars(A, B) when is_binary(A) andalso is_binary(B) ->
  maybe_drop_chars({last_char(A), A}, {first_char(B), B});
maybe_drop_chars({LastCharA, A}, {LastCharB, B}) ->
  case is_different_polarity(LastCharA, LastCharB) of
    true ->
      maybe_drop_chars(all_but_last(A), all_but_first(B));
    false ->
      {A, B}
  end.

is_different_polarity(A, B) ->
  AA = ascii(A),
  AB = ascii(B),
  AA =:= AB + 32 orelse AA + 32 =:= AB.

ascii(X) when is_binary(X) -> ascii(b2l(X));
ascii(X) ->
  list_to_integer((lists:flatmap(fun erlang:integer_to_list/1, X))).

first_char(Polymer) ->
  Size = byte_size(Polymer),
  binary:part(Polymer, {Size - Size, Size - Size + 1}).

last_char(Polymer) ->
  Size = byte_size(Polymer),
  binary:part(Polymer, {Size, -1}).

all_but_first(<<>>) -> <<>>;
all_but_first(Polymer) ->
  Size = byte_size(Polymer),
   binary_part(Polymer, {Size - Size + 1, Size - 1}).

all_but_last(<<>>) -> <<>>;
all_but_last(Polymer) ->
  binary_part(Polymer, {0, byte_size(Polymer) - 1}).

push(A, B) ->
  {NewA, NewB} = maybe_drop_chars(A, B),
  l2b(b2l(NewA) ++ b2l(NewB)).

push(A, B, C) -> l2b(b2l(A) ++ b2l(B) ++ b2l(C)).

b2l(X) -> binary_to_list(X).
l2b(X) -> list_to_binary(X).

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
