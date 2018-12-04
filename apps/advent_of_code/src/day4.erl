-module(day4).

-export([ run/0
        ]).

-define(awake, "wakes up").
-define(sleep, "falls asleep").

-spec run() -> [{atom(), integer()}].
run() ->
  Input = input(),
  SleepRythm = sleep_rythm(Input, {first_guard(Input), dict:new()}),
  SleepySums = sort_sleepy_by(SleepRythm, sum),
  SleepyMinutes = sort_sleepy_by(SleepRythm, minute),
  {GuardA, _} = hd(SleepySums),
  {{GuardB, MinuteB}, _} = hd(SleepyMinutes),
  MinuteA = most_sleepy_minute(GuardA, SleepyMinutes),
  [ {a, GuardA * MinuteA}
  , {b, GuardB * MinuteB}
  ].

input() ->
  {ok, Bin} = file:read_file(code:priv_dir(advent_of_code) ++ "/day4.txt"),
  L = string:tokens(binary_to_list(Bin), "\n"),
  Parsed = lists:map(
             fun(Line) ->
                 [Ts, Action] = string:tokens(Line, "[]"),
                 {Ts, parse_action(Action)}
             end, L),
  lists:sort(fun({T1,_}, {T2,_}) -> T1 < T2 end, Parsed).

parse_action(" Guard #" ++ _ = Action) -> guard_to_integer(Action);
parse_action(" falls asleep") -> ?sleep;
parse_action(" wakes up") -> ?awake.

guard_to_integer(A) ->
  [_, IdStr, _, _] = string:tokens(A, "# "),
  list_to_integer(IdStr).

first_guard([{_TimeStamp, GuardId}|_]) -> GuardId.

sleep_rythm([], {_, Dict}) -> Dict;
sleep_rythm([{_Time1, Id}| T], {_, Dict}) when is_integer(Id) ->
  sleep_rythm(T, {Id, Dict});
sleep_rythm([{Time1, ?sleep}, {Time2, ?awake} | T], {LastId, Dict}) ->
  NewDict = add_sleep(Time1, Time2, LastId, Dict),
  sleep_rythm(T, {LastId, NewDict}).

add_sleep(Time1, Time2, LastId, Dict) ->
  do_add_sleep(start_minute(Time1), calc_diff(Time1, Time2), LastId, Dict).

do_add_sleep(M, Diff, _, Dict) when M =:= 60 orelse Diff =:= 0 -> Dict;
do_add_sleep(M, Diff, Id, Dict) ->
  do_add_sleep(M + 1, Diff - 1, Id, dict:update_counter({Id, M}, 1, Dict)).

calc_diff(Time1, Time2) ->
  [_,H1,M1] = string:tokens(Time1, " :"),
  [_,H2,M2] = string:tokens(Time2, " :"),
  (l2i(H2) * 60 + l2i(M2)) - (l2i(H1) * 60 + l2i(M1)).

start_minute(Time) ->
  [_,_,M] = string:tokens(Time, " :"),
  l2i(M).

sort_sleepy_by(SleepRythm, sum) ->
  SumSleepsDict = sum_sleeps(SleepRythm),
  lists:sort(fun({_, C1}, {_, C2}) -> C1 > C2 end, dict:to_list(SumSleepsDict));
sort_sleepy_by(SleepRythm, minute) ->
  lists:sort(
    fun({{_, _}, C1}, {{_, _}, C2}) ->
        C1 > C2
    end, dict:to_list(SleepRythm)).

sum_sleeps(SleepRythm) ->
  lists:foldl(fun({{Id, _M}, C}, D) ->
                  dict:update(Id, fun(Old) -> Old + C end, C, D)
              end, dict:new(), dict:to_list(SleepRythm)).

most_sleepy_minute(_, []) -> {error, most_sleepy_minute_not_found};
most_sleepy_minute(Id, [{{Id, M}, _}| _]) -> M;
most_sleepy_minute(Id, [_|T]) -> most_sleepy_minute(Id, T).

l2i(X) -> list_to_integer(X).

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
