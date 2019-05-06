:- lib(ic).
:- lib(branch_and_bound).
:- lib(listut).

evalLiteral(L, S, Elem) :-
    L > 0,
    nth1(L, S, Elem).
evalLiteral(L, S, Elem1) :-
    L < 0,
    Lindex is -L,
    nth1(Lindex, S, Elem),
    Elem1 #:: 0..1,
    Elem1 #\= Elem.

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
    % create_formula(NV, NC, D, F),
    % F = [[-4], [-4, -5], [3, -4], [-1], [-2, 5], [], [1, 4],
    % [3, 5], [], [4], [1, 2, -4, -5], [-3], [-4], [-3], [],
    % [1], [-5], [1, -5], [], [1, -4]],
    F = [[1,-2,4],[-1,2],[-1,-2,3],[-2,-4],[2,-3],[1,3],[-3,4]],
    length(S, NV),
    S #:: 0..1,
    evalCNF(F, S, M),
    NegM #= -M,
    bb_min(labeling(S), NegM, _).
    % bb_min(labeling(S), NegM, bb_options{solutions:all}).
