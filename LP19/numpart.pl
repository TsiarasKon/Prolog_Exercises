:- lib(fd).
:- lib(fd_global).
:- lib(fd_search).

numpart(N, L1, L2) :-
    mod(N, 2, 0),
    HalfN is integer(N / 2),
    length(L1, HalfN),
    length(L2, HalfN),
    [L1, L2] #:: 1..N,
    sumlist(L1, SumL),
    sumlist(L2, SumL),
    % ascendingList(L1),
    % ascendingList(L2),
    ordered(<, L1),
    ordered(<, L2),
    firstList(L1, L2),
    append(L1, L2, L),
    fd_global:alldifferent(L),
    search([L1, L2], 0, input_order, indomain, complete, []),
    powList(L1, 2, SquareL1),
    powList(L2, 2, SquareL2),
    sumlist(SquareL1, SquareSumL),
    sumlist(SquareL2, SquareSumL).

ascendingList([]).
ascendingList([_]).
ascendingList([X, Y | L]) :-
    X #< Y,
    ascendingList([Y | L]).

firstList([X | _], [Y | _]) :-
    X #< Y.

powList([], _, []).
powList([X | L], Pow, [PowX | PowL]) :-
    PowX is X ^ Pow,
    powList(L, Pow, PowL).
