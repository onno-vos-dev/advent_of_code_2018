-module(day1).

-export([ run/0
        ]).

-spec run() -> [{atom(), integer()}].
run() ->
  put(input, input()),
  [ {a, a()}
  , {b, b()}
  ].

input() ->
  {ok, Bin} = file:read_file(code:priv_dir(advent_of_code) ++ "/day1.txt"),
  [ list_to_integer(I) || I <- string:tokens(binary_to_list(Bin), "\n") ].

a() ->
  lists:sum(get(input)).

b() ->
  b(get(input), {0, dict:new()}).

b([], Acc) -> b(get(input), Acc); %% Repeat
b([H|T], {Freq, D}) ->
  NewFreq = Freq + H,
  case dict:is_key(NewFreq, D) of
    true -> NewFreq;
    false -> b(T, {NewFreq, dict:store(NewFreq, '_', D)})
  end.

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
