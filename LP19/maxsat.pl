:- lib(ic).
:- lib(branch_and_bound).

my_nth1(1, [X | _], X).
my_nth1(N, [_ | L], Y) :-
    N > 1,
    N1 is N - 1,
    my_nth1(N1, L, Y).

evalLiteral(L, S, V) :-
    L > 0,
    my_nth1(L, S, V).
evalLiteral(L, S, V1) :-
    L < 0,
    Lindex is -L,
    my_nth1(Lindex, S, V),
    V1 #:: 0..1,
    V1 #\= V.

evalClause([], _, 0).
evalClause([L | Rest], S, FinalV) :-
    evalLiteral(L, S, LV),
    evalClause(Rest, S, CurrV),
    maxlist([LV, CurrV], FinalV).

evalCNF([], _, 0).
evalCNF([C | Rest], S, M1) :-
    evalCNF(Rest, S, M),
    evalClause(C, S, Value),
    M1 #= M + Value.

maxsat(NV, NC, D, F, S, M) :-
    create_formula(NV, NC, D, F),
    length(S, NV),
    S #:: 0..1,
    evalCNF(F, S, M),
    NegM #= -M,
    bb_min(labeling(S), NegM, bb_options{strategy:dichotomic}).
