:- lib(ic).
:- lib(branch_and_bound).

myCount([], X, 0).
myCount([X | L], X, N1) :-
    myCount(L, X, N),
    N1 is N + 1.
myCount([Y | L], X, N) :-
    Y \= X,
    myCount(L, X, N).


maxsat(NV, NC, D, F, S, M) :-
    create_formula(NV, NC, D, F),
    length(S, NV),
    S #:: 0..1,
    myCount(S, 1, M),
    % NegM #:: -M,
    bb_min(labeling(S), M, _).
