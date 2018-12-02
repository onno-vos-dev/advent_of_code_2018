-module(day2).

-export([ run/0
        ]).

-spec run() -> [{atom(), integer()}].
run() ->
  put(input, input()),
  [ {a, a()}
  , {b, b()}
  ].

input() ->
  {ok, Bin} = file:read_file(code:priv_dir(advent_of_code) ++ "/day2.txt"),
  string:tokens(binary_to_list(Bin), "\n").

a() ->
  Input = get(input),
  R = lists:foldl(
        fun(String, Dict) ->
            lists:foldl(
              fun(Count, D) ->
                  dict:update_counter(Count, 1, D)
              end, Dict, a(String, dict:new()))
        end, dict:new(), Input),
  [{_, C1}, {_, C2}] = dict:to_list(R),
  C1 * C2.

a([], Dict) ->
  lists:usort(
    lists:filtermap(
      fun({_, Count}) when Count =:= 2 orelse Count =:= 3 -> {true, Count};
         (_) -> false
      end, dict:to_list(Dict)));
a([H | T], Dict) ->
  a(T, dict:update_counter(H, 1, Dict)).

b() ->
  Dict = lists:foldl(
           fun(String, D) ->
               dict:store(String, 0, D)
           end, dict:new(), get(input)),
  put(b, get(input)), %% Copy input so we avoid iterating over keys twice
  R =
    lists:flatten(
      lists:foldl(
        fun(String, Acc) ->
            put(b, get(b) -- [String]),
            R = lists:filter(
                  fun({_, C}) ->
                      C =:= 1
                  end, find_almost_matching_string(String, 1, Dict)),
            [R | Acc]
        end, [], get(input))),
  lists:filtermap(fun({C1, C2}) when C1 =:= C2 -> {true, C1};
                     (_) -> false
                  end, lists:zip(element(1, hd(R)), element(1, lists:last(R)))).

find_almost_matching_string([], _Counter, Acc) -> dict:to_list(Acc);
find_almost_matching_string([H | T], Counter, Acc) ->
  NewAcc = lists:foldl(
             fun(String, A) ->
                 case lists:nth(Counter, String) =:= H of
                   false -> dict:update_counter(String, 1, A);
                   true -> A
                 end
             end, Acc, get(b)),
  find_almost_matching_string(T, Counter + 1, NewAcc).

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
