:- lib(fd).
:- lib(fd_global).
:- lib(fd_search).

numpart(N, L1, L2) :-
    mod(N, 2, 0),
    HalfN is integer(N / 2),
    length(L1, HalfN),
    length(L2, HalfN),
    [L1, L2] #:: 1..N,
    sumlist(L1, SumL1),
    sumlist(L2, SumL2),
    SumL1 #= SumL2,
    ascendingList(L1),
    ascendingList(L2),
    firstList(L1, L2),
    append(L1, L2, L),
    fd_global:alldifferent(L),
    % difference([1, 2, 3, 4, 5, 6, 7, 8], L1, L2),
    % fd_global:alldifferent([L1, L2]),
    % sumPowList(L1, 2, SumSquareL1),
    % sumPowList(L2, 2, SumSquareL2),
    % SumSquareL1 #= SumSquareL2,
    search([L1, L2], 0, first_fail, indomain, complete, []).

ascendingList([]).
ascendingList([_]).
ascendingList([X, Y | L]) :-
    X #< Y,
    ascendingList([Y | L]).

firstList([X | _], [Y | _]) :-
    X #< Y.