-module(day5_ascii_solution).

-export([ run/0
        , benchmark/0
        , input/0
        ]).

-define(is_same(A, B), A + 32 =:= B orelse A =:= B + 32).

-spec run() -> [{atom(), integer()}].
run() ->
  Input = input(), %"dabAcCaCBAcCcaDA",
  PolymerA = a(Input),
  [ {a, length(PolymerA)}
  , {b, hd(b(Input, PolymerA))}
  ].

input() ->
  {ok, Bin} = file:read_file(code:priv_dir(advent_of_code) ++ "/day5.txt"),
  string:trim(binary_to_list(Bin)).

a(Input) ->
  polymer(Input, "").

b(Input, Polymer) ->
  UniqChars = lists:usort(string:to_upper(Input)),
  lists:sort(fun(L1, L2) ->
                 L1 < L2
             end, [ partb(Char, Polymer) || Char <- UniqChars ]).

partb(H, Polymer) ->
  Rex = "["++string:to_upper(lists:flatten([H])) ++ string:to_lower(lists:flatten([H]))++"]",
  Input = re:replace(Polymer, Rex, "", [global, {return, list}]),
  length(polymer(Input, "")).

polymer([], P) -> lists:reverse(P);
polymer([H], [PH|PT]) when ?is_same(H, PH) -> lists:reverse(PT);
polymer([H], P) -> lists:reverse([H|P]);
polymer([H|T], [PH|PT]) when ?is_same(H, PH) -> polymer(T, PT);
polymer([H|T], P) -> polymer(T, [H|P]).

benchmark() ->
  {I, Tmicro} =
    lists:foldl(
      fun(I, {_, Ta}) ->
          S = erlang:timestamp(),
          day5_ascii_solution:run(),
          T = timer:now_diff(erlang:timestamp(), S),
          {I, Ta + T}
      end, {0, 0}, lists:seq(1,100)),
  io:format("Average for ~p iterations => ~p microseconds~n", [I, (Tmicro/I)]).

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
