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
    append(L1, L2, L),
    fd_global:alldifferent(L),
    firstList(L1, L2),
    ordered(<, L1),
    ordered(<, L2),
    search([L1, L2], 0, first_fail, indomain, complete, []),
    powListSum(L1, 2, SquareSum),
    powListSum(L2, 2, SquareSum).

% used to avoid duplicate results
firstList([X | _], [Y | _]) :-
    X #< Y.

powListSum([], _, 0).
powListSum([X | L], Pow, PowSum) :-
    powListSum(L, Pow, PowSumRest),
    Curr is X ^ Pow,
    PowSum is PowSumRest + Curr.
