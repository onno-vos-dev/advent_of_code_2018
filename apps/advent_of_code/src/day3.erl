-module(day3).

-export([ run/0
        ]).

-spec run() -> [{atom(), integer()}].
run() ->
  Input = input(),
  {Ids, ClaimedArea} = area(Input, {[], maps:new()}),
  Map = get_overlaps(ClaimedArea),
  [ {a, maps:fold(fun(_K, V, Acc) -> V + Acc end, 0, Map)}
  , {b, Ids -- lists:flatten(maps:keys(Map))}
  ].

input() ->
  {ok, Bin} = file:read_file(code:priv_dir(advent_of_code) ++ "/day3.txt"),
  string:tokens(binary_to_list(Bin), "\n").

area([], {Ids, M}) -> {Ids, M};
area([Hd | Tl], {Ids, M}) ->
  [Id, L, T, W, H] = [ list_to_integer(V) || V <- string:tokens(Hd, "#@ ,:x")],
  XYs = [{X, Y} || X <- lists:seq(L, L + W - 1), Y <- lists:seq(T, T + H - 1)],
  NewM = lists:foldl(fun(XY, Map) ->
                         Old = maps:get(XY, Map, []),
                         Map#{XY => [Id | Old]}
                     end, M, XYs),
  area(Tl, {[Id | Ids], NewM}).

get_overlaps(Map) ->
  maps:fold(
    fun(_K, V, M) when length(V) >= 2 ->
        M#{V => maps:get(V, M, 0) + 1};
       (_, _, M) -> M
    end, maps:new(), Map).

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
