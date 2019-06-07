:- lib(ic).

activity(a1, act(0,3)).
activity(a2, act(4,6)).
activity(a3, act(1,2)).

% https://stackoverflow.com/questions/48937374/clp-constraints-on-structured-variables

assignment_opt(NF, NP, ST, F, T, ASP, ASA, Cost) :-
	NF == 0,
	findall((A, AStart, AEnd), activity(A, act(AStart, AEnd)), AL),
	generateALs(AL, ALStart, ALEnd),
	calcD(ALStart, ALEnd, D),
	calcA(NP, D, A),
	ALLen is length(AL),
	constraintASA(NP, ALLen, ASAN),
	generateASP(NP, 1, ALLen, ALStart, ALEnd, ASA, ST, ASP),
	calcCost(ASP, A, Cost),
    bb_min(labeling(ASA), Cost, _).
	% reverse(RevASP, ASP),
	% sort(ASAunsorted, ASA).

% assignment_opt(NF, NP, ST, F, T, ASP, ASA, Cost) :-
% 	NF > 0,
% 	findall(A, activity(A, act(_, _)), AL),
% 	createStartingASP(NP, StartingASP),
% 	length(ALNF, NF),
% 	append(ALNF, _, AL),
% 	calcD(ALNF, D),
% 	calcA(NP, D, A),
% 	assignmentHelper(ST, RevASP, _, StartingASP, ALNF),
% 	calcCost(RevASP, A, Cost),
% 	reverse(RevASP, ASP),
% 	generateASA(ASP, ASAunsorted),
% 	sort(ASAunsorted, ASA).

generateALs([], [], []).
generateALs([activity(_, act(AStart, AEnd)) | ALRest], [AStart | ALStartRest], [AEnd | ALEndRest]) :-
	generateALs(ALRest, ALStartRest, ALEndRest).

calcD([], [], 0).
calcD([AStart | ALStartRest], [AEnd | ALEndRest], D) :-
	calcD(ALStartRest, ALEndRest, D1),
	D is D1 + AEnd - AStart.

calcA(NP, D, A) :-
	NP > 0,
	Fraction is D / NP,
	A is integer(round(Fraction)).

calcCost([], _, 0).
calcCost([_ - _ - Wi | ASP], A, Cost) :-
	calcCost(ASP, A, Cost1),
	CurrCost #= (A - Wi) ^ 2,
	Cost #= CurrCost + Cost1.

calcCostASA(NP, CurrN, _, _, _, 0) :-
	CurrN > NP, !.
calcCostASA(NP, CurrN, [], ASA, A, Cost) :-
	NewN is CurrN + 1,
	calcCostASA(NP, NewN, ASA, ASA, A, Cost).
calcCostASA(NP, CurrN, [_ - N | ASARest], ASA, A, Cost) :-
	N #= CurrN,
	calcCostASA(NP, CurrN, ASARest, ASA, A, Cost1),
	CurrCost #= (A - Wi) ^ 2,
	Cost #= CurrCost + Cost1.
calcCostASA(NP, CurrN, [_ - N | ASARest], ASA, A, Cost) :-
	CurrN #\= N,
	calcCostASA(NP, CurrN, ASARest, ASA, A, Cost).
%%%%
generatePersonASA(_, [], []).
generatePersonASA(N, [A | ALRest], [A - N | PersonASARest]) :-
	generatePersonASA(N, ALRest, PersonASARest).

generateASA([], []).
generateASA([N - AL - _ | ASPRest], ASA) :-
	generatePersonASA(N, AL, PersonASA),
	generateASA(ASPRest, ASARest),
	append(ASARest, PersonASA, ASA).


generatePersonASP(_, _, _, _, [], _, [], 0).
generatePersonASP(N, ALLen, ALStart, ALEnd, [AN - N | ASARest], ST, [ANPerson | ALPersonRest], TSum) :-
	AN #:: 1..ALLen,
	AN #= ANPerson,
	generatePersonASP(N, ALLen, ALStart, ALEnd, ASARest, ST, ALPersonRest, TSum1),
	element(ANPerson, ALStart, AStart),
	element(ANPerson, ALEnd, AEnd),
	TSum #= TSum1 + AEnd - AStart.
generatePersonASP(N, ALLen, ALStart, ALEnd, [A - NOther | ASARest], ST, AL, TSum) :-
	NOther #\= N,
	generatePersonASP(N, ALLen, ALStart, ALEnd, ASARest, ST, AL, TSum).

generateASP(NP, N, _, _, _, _, _, []) :-
	N > NP.
generateASP(NP, N, ALLen, ALStart, ALEnd, ASA, ST, [N - ALPerson - TSum | ASPRest]) :-		% call with N = 1
	N =< NP,
	TSum #:: 0..ST,
	generatePersonASP(N, ALLen, ALStart, ALEnd, ASA, ST, ALPerson, TSum),
	N1 is N + 1,
	generateASP(NP, N1, ALStart, ALEnd, ALLen, ASA, ST, ASPRest).
%%%

assignToPerson(N, [], N - [] - 0).
assignToPerson(N, AL, N - [A | ALPersonRest] - TSum) :-
	member(A, AL),
	activity(A, act(AStart, AEnd)),
	% sorted([A | ALPersonRest]),
	delete(A, AL, AL1),
	assignToPerson(N, AL1, N - ALPersonRest - TSum1),
	listTimeCheck(ALPersonRest, AStart, AEnd),
	Tsum #= TSum1 + AEnd - AStart.
assignToPerson(N, AL, N - ALPerson - TSum) :-
	member(A, AL),
	delete(A, AL, AL1),
	assignToPerson(N, AL1, N - ALPerson - TSum).

constraintASAMembers(_, [], []).
constraintASAMembers(NP, [ALNums | ALNumsRest], [ANum - N | ASAN]) :-
	N #:: 1..NP,
	constraintASAMembers(NP, ALNumsRest, ASAN).

constraintASA(NP, ALLen, ASAN) :-
	length(ALNums, ALLen),
	ALNums #:: 1..ALLen,
	alldifferent(ALNums),
	constraintASAMembers(NP, ALNums, ASAN).

listlistTimeCheck([]).
listlistTimeCheck([A | NL]) :-
	activity(A, act(AStart, AEnd)),
	listTimeCheck(NL, AStart, AEnd),
	listlistTimeCheck(NL).

timeCheckNLX([]).
timeCheckNLX([_]).
timeCheckNLX([(_, _, A1End), (_, A2Start, A2End) | NLRest]) :-
	A1End #< A2Start,
	timeCheckNLX([(_, A2Start, A2End) | NLRest]).
	% ST check?

% timeCheckNLX(ST, [], _).
% timeCheckNLX(ST, [(_, AStart, AEnd)]) :-
% 	ST #>= AEnd - AStart.
% timeCheckNLX(ST, [(_, A1Start, A1End), (_, A2Start, A2End) | NLRest], TSum) :-
% 	A1End #< A2Start,
% 	timeCheckNLX([(_, A2Start, A2End) | NLRest]).

%%%

createStartingASP(0, []).
createStartingASP(N, [N - [] - 0 | ASPRest]) :-
	N > 0,
	N1 is N - 1,
	createStartingASP(N1, ASPRest).

assignmentHelper(_, ASP, [], ASP, []).
assignmentHelper(ST, ASP, [A - N | ASARest], ASPBefore, [A | ALRest]) :-
	assignActivity(A, ST, ASPBefore, ASPAfter, N),
	assignmentHelper(ST, ASP, ASARest, ASPAfter, ALRest).

assignActivity(A, ST, ASPBefore, ASPAfter, N) :- 
	append(ASP1, [N - NL - TSum | ASP2], ASPBefore),
	activity(A, act(AStart, AEnd)),
	canBeAssigned(AStart, AEnd, N, NL, ASPBefore),
	TSum1 is TSum + AEnd - AStart,
	TSum1 =< ST,
	append(ASP1, [N - [A | NL] - TSum1 | ASP2], ASPAfter).

canBeAssigned(AStart, AEnd, N, NL, ASP) :-
	firstOfItsKind(N - NL, ASP),
	listTimeCheck(NL, AStart, AEnd).

% acts both as "member()" and to ensure that not all (N!) assignments won't be output
firstOfItsKind(N - NL, [N - NL - _ | _]).
firstOfItsKind(N - NL, [_ - L - _ | ASPRest]) :-
	NL \= L,
	firstOfItsKind(N - NL, ASPRest).

% ensures that a newly assigned activity to a person is at least 1 unit of time after their last one
listTimeCheck([], _, _).
listTimeCheck([PastA | NL], AStart, AEnd) :-
	activity(PastA, act(PastAStart, PastAEnd)),
	(AEnd #< PastAStart; AStart #> PastAEnd),
	listTimeCheck(NL, AStart, AEnd).
