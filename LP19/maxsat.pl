:- lib(ic).
:- lib(branch_and_bound).
:- lib(listut).

myCount([], _, 0).
myCount([X | L], X, N1) :-
    myCount(L, X, N),
    N1 is N + 1.
myCount([Y | L], X, N) :-
    Y \= X,
    myCount(L, X, N).

evalClause([], _, 0).
evalClause([L | _], S, 1) :-
    L > 0,
    nth1(L, S, Elem),
    Elem is 1, !.
evalClause([L | _], S, 1) :-
    L < 0,
    Lindex = -L,
    nth1(Lindex, S, Elem),
    Elem is 0, !.
evalClause([_ | Rest], S, Value) :-
    evalClause(Rest, S, Value).

evalCNF([], _, 0).
evalCNF([C | Rest], S, M1) :-
    evalClause(C, S, Value),
    evalCNF(Rest, S, M),
    M1 is M + Value.

maxsat(NV, NC, D, F, S, M) :-
    create_formula(NV, NC, D, F),
    length(S, NV),
    S #:: 0..1,
    myCount(S, 1, M),
    % NegM #:: -M,
    bb_min(labeling(S), M, _).
