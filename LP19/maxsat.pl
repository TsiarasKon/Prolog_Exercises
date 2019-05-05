:- lib(ic).
:- lib(ic_global).
:- lib(branch_and_bound).
:- lib(listut).



evalClause([], _, 0).
evalClause([L | _], S, 1) :-
    L > 0,
    element(L, S, Elem),
    Elem #= 1.
evalClause([L | _], S, 1) :-
    L < 0,
    Lindex is -L,
    element(Lindex, S, Elem),
    Elem #= 0.
evalClause([_ | Rest], S, Value) :-
    evalClause(Rest, S, Value).

% evalClause([], _, 0).
% evalClause([L | _], S, Elem) :-
%     L > 0,
%     nth1(L, S, Elem), !.
% evalClause([L | _], S, Elem1) :-
%     L < 0,
%     Lindex is -L,
%     nth1(Lindex, S, Elem),
%     Elem1 #= Elem + 1, !.
% evalClause([_ | Rest], S, Value) :-
%     evalClause(Rest, S, Value).


evalCNF([], _, 0).
evalCNF([C | Rest], S, M1) :-
    evalCNF(Rest, S, M),
    evalClause(C, S, Value),
    M1 #= M + Value.

maxsat(NV, NC, D, F, S, M) :-
    % create_formula(NV, NC, D, F),
    % F = [[1], [-2], [-1, -2], []],
    F = [[-4], [-4, -5], [3, -4], [-1], [-2, 5], [], [1, 4],
    [3, 5], [], [4], [1, 2, -4, -5], [-3], [-4], [-3], [],
    [1], [-5], [1, -5], [], [1, -4]],
    % F = [[1,-2,4],[-1,2],[-1,-2,3],[-2,-4],[2,-3],[1,3],[-3,4]],
    length(S, NV),
    S #:: 0..1,
    write(S),
    nl,
    isFirst(S, XX),
    write(XX),
    nl,
    % occurrences(1, S, M),
    evalCNF(F, S, M),
    NegM #= -M,
    bb_min(labeling(S), NegM, _).


% F = [[-4], [-4, -5], [3, -4], [-1], [-2, 5], [], [1, 4],
%  [3, 5], [], [4], [1, 2, -4, -5], [-3], [-4], [-3], [],
%  [1], [-5], [1, -5], [], [1, -4]], evalCNF(F, [1, 1, 0, 0, 1], M).

isFirst([Y | _], X) :-
    X #= Y.