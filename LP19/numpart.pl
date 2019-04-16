:- lib(fd).
:- lib(fd_global).
:- lib(fd_search).

numpart(N, L1, L2) :-
    mod(N, 2, 0),
    HalfN is integer(N / 2),
    length(L1, HalfN),
    length(L2, HalfN),
    squareList(L1, SqL1),
    squareList(L2, SqL2),
    [L1, L2] #:: 1..N,
    firstList(L1, L2),
    append(L1, L2, L),
    fd_global:alldifferent(L),
    ordered(<, L1),
    ordered(<, L2),
    sumlist(L1, SumL),
    sumlist(L2, SumL),
    sumlist(SqL1, SqSumL),
    sumlist(SqL2, SqSumL),
    search([L1, L2], 0, first_fail, indomain_reverse_min, complete, []).
    % powListSum(L1, 2, SquareSum),
    % powListSum(L2, 2, SquareSum).

% used to avoid duplicate results
firstList([X | _], [Y | _]) :-
    X #< Y.

squareList([], []).
squareList([X | L], [SqX | SqL]) :-
    SqX #= X * X,
    squareList(L, SqL).

powListSum([], _, 0).
powListSum([X | L], Pow, PowSum) :-
    powListSum(L, Pow, PowSumRest),
    Curr is X ^ Pow,
    PowSum is PowSumRest + Curr.
