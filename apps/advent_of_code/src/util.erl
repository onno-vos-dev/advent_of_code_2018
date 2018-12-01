-module(util).

-export([ time_avg/2
        ]).

time_avg(Fun, X) ->
  lists:sum(
    lists:map(fun(_) ->
                  {Avg, _} = timer:tc(fun() -> Fun() end),
                  Avg
              end, lists:seq(1, X))) / X.

%%%_* Emacs ====================================================================
%%% Local Variables:
%%% allout-layout: t
%%% erlang-indent-level: 2
%%% End:
