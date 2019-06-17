:- lib(ic).
:- lib(branch_and_bound).

% first sort all the activities based on their start time
% then constrain that ordered ASA (ASAN) on the premise that a person can only be assigned an activity if:
%	1) The activity's start time is greater than the max end time of all the previous activities
%	2) The total assigned activity time for that person is less than ST
% then calculate the cost, search possible assignments using bb_min/3 with that cost
% and finally generate the required ASA and ASP for the chosen solution

assignment_opt(NF, NP, ST, F, T, ASP, ASA, Cost) :-
	getAL(NF, ALun),
	insertsort(ALun, AL),
	calcD(AL, D),
	calcA(NP, D, A),
	MinCost is abs(NP*A - D),	 
	ALLen is length(AL),
	length(ASAN, ALLen),
	ASAN #:: 1..NP,
	orderASANfirst(ASAN, NP, 1),
	orderASAN(ASAN, NP, 1),
	constraintASAN(AL, AL, ASAN, ASAN, NP, 1, -1),
	length(Ws, NP),
	Ws #:: 0..ST,
	calcWs(AL, AL, ASAN, ASAN, ST, 1, Ws),
	Cost #:: MinCost..NP*A^2,
	calcCost(Ws, A, Cost),
	bb_min(labeling(ASAN), Cost, bb_options{delta:F, timeout:T}),
	generateASA(AL, ASAN, ASAun),
	sort(ASAun, ASA),
	generateASP(ASA, Ws, 1, ASP).

% the minimum possible cost is evident from its type:
% the best case scenario is for every person to have Wi = A, 
% but when D is not a multiple of NP that won't be possible for all people
% for example, for NP = 5, D = 28 ==> A = 6 and assuming perfect assignment distribution, 
%   3 people will have Wi = 6 and 2 will have Wi = 5, reulting in a MinCost of 2.
% we can formulate that to MinCost = abs(NP*A - D)

getAL(0, AL) :-
	findall((A, AStart, AEnd), activity(A, act(AStart, AEnd)), AL).
getAL(NF, ALNF) :-
	NF > 0,
	findall((A, AStart, AEnd), activity(A, act(AStart, AEnd)), AL),
	length(ALNF, NF),
	append(ALNF, _, AL).

insertsort([], []).
insertsort([X | Tail], Sorted) :-
	insertsort(Tail, SortedTail),
	insert(X, SortedTail, Sorted).

insert((A1, AStart1, AEnd1), [(A2, AStart2, AEnd2) | Sorted], [(A2, AStart2, AEnd2) | Sorted1]) :-
	AStart1 > AStart2, !,
	insert((A1, AStart1, AEnd1), Sorted, Sorted1).
insert(X, Sorted, [X | Sorted]).

calcD([], 0).
calcD([(_, AStart, AEnd) | ALRest], D) :-
	calcD(ALRest, D1),
	D is D1 + AEnd - AStart.

calcA(NP, D, A) :-
	NP > 0,
	Fraction is D / NP,
	A is integer(round(Fraction)).

calcCost([], _, 0).
calcCost([Wi | WsRest], A, Cost) :-
	calcCost(WsRest, A, Cost1),
	CurrCost #= (A - Wi) ^ 2,
	Cost #= CurrCost + Cost1.

% check uniqueness of solutions similar to Assignment 2
% the first NP activities can easily constrained based on that
orderASANfirst([], _, _).
orderASANfirst(_, NP, CurrN) :-
	CurrN > NP, !.
orderASANfirst([N | ASANRest], NP, CurrN) :-
	N #:: 1..CurrN,
	N1 is CurrN + 1,
	orderASANfirst(ASANRest, NP, N1).

orderASAN([], _, _).
orderASAN([N | ASANRest], NP, CurrN) :-
	N #:: 1..NP,
	[CurrN, NewCurrN] #:: 1..NP + 1,
	(CurrN #> NP, NewCurrN #= CurrN) or (N #< CurrN, NewCurrN #= CurrN) or (N #= CurrN, NewCurrN #= CurrN + 1),
	orderASAN(ASANRest, NP, NewCurrN).

calcWs(_, _, _, _, _, _, []).
calcWs(AL, [], ASAN, [], ST, N, [0 | WsRest]) :-
	N1 is N + 1,
	calcWs(AL, AL, ASAN, ASAN, ST, N1, WsRest).
calcWs(AL, [(_, AStart, AEnd) | ALRest], ASAN, [AN | ASANRest], ST, N, [WiNew | WsRest]) :-
	WiNew #:: 0..ST,
	(AN #= N, WiNew #= Wi + AEnd - AStart) or (AN #\= N, WiNew #= Wi),
	calcWs(AL, ALRest, ASAN, ASANRest, ST, N, [Wi | WsRest]).

constraintASAN(_, _, _, _, NP, N, _) :-
	N > NP, !.
constraintASAN(AL, [], ASAN, [], NP, N, _) :-
	N1 is N + 1,
	constraintASAN(AL, AL, ASAN, ASAN, NP, N1, -1).
constraintASAN(AL, [(_, AStart, AEnd) | ALRest], ASAN, [AN | ASANRest], NP, N, PrevLatestN) :-
	(AN #= N, PrevLatestN #< AStart, (PrevLatestN #> AEnd, NextLatestN #= PrevLatestN) or (NextLatestN #= AEnd)) or (AN #\= N, NextLatestN #= PrevLatestN),
	constraintASAN(AL, ALRest, ASAN, ASANRest, NP, N, NextLatestN).

generateASA([], [], []).
generateASA([(A, _, _) | ALRest], [N | ASANRest], [A - N | ASARest]) :-
	generateASA(ALRest, ASANRest, ASARest).

generateASP(_, [], _, []).
generateASP(ASA, [Wi | WRest], N, [N - ALN - Wi | ASPRest]) :-
	generatePersonAL(ASA, N, ALN),
	N1 is N + 1,
	generateASP(ASA, WRest, N1, ASPRest).

generatePersonAL([], _, []).
generatePersonAL([A - N | ASARest], N, [A | ALRest]) :-
	generatePersonAL(ASARest, N, ALRest).
generatePersonAL([_ - NOther | ASARest], N, AL) :-
	NOther \= N,
	generatePersonAL(ASARest, N, AL).
