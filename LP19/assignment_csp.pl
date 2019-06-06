:- lib(ic).

activity(a1, act(0,3)).
activity(a2, act(4,6)).
activity(a3, act(1,2)).

assignment_opt(NF, NP, ST, F, T, ASP, ASA, Cost) :-
	NF == 0,
	findall(A, activity(A, act(_, _)), AL),
	createStartingASP(NP, StartingASP),
	calcD(AL, D),
	calcA(NP, D, A),
	assignmentHelper(ST, RevASP, _, StartingASP, AL),
	calcCost(RevASP, A, Cost),
	reverse(RevASP, ASP),
	generateASA(ASP, ASAunsorted),
	sort(ASAunsorted, ASA).

assignment_opt(NF, NP, ST, F, T, ASP, ASA, Cost) :-
	NF > 0,
	findall(A, activity(A, act(_, _)), AL),
	createStartingASP(NP, StartingASP),
	length(ALNF, NF),
	append(ALNF, _, AL),
	calcD(ALNF, D),
	calcA(NP, D, A),
	assignmentHelper(ST, RevASP, _, StartingASP, ALNF),
	calcCost(RevASP, A, Cost),
	reverse(RevASP, ASP),
	generateASA(ASP, ASAunsorted),
	sort(ASAunsorted, ASA).

calcD([], 0).
calcD([A | AL], D) :-
	calcD(AL, D1),
	activity(A, act(AStart, AEnd)),
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
%%%%
generatePersonASA(_, [], []).
generatePersonASA(N, [A | ALRest], [A - N | PersonASARest]) :-
	generatePersonASA(N, ALRest, PersonASARest).

generateASA([], []).
generateASA([N - AL - _ | ASPRest], ASA) :-
	generatePersonASA(N, AL, PersonASA),
	generateASA(ASPRest, ASARest),
	append(ASARest, PersonASA, ASA).


generatePersonASP(_, [], [], 0).
generatePersonASP(N, [A - N | ASARest], [A | ALRest], TSum) :-
	activity(A, act(AStart, AEnd)),
	generatePersonASP(N, ASARest, ALRest, TSum1),
	TSum is TSum1 + AEnd - AStart.
generatePersonASP(N, [A - NOther | ASARest], AL, TSum) :-
	NOther \= N,
	generatePersonASP(N, ASARest, AL, TSum).

generateASP(NP, N, _, []) :-
	N > NP.
generateASP(NP, N, ASA, [N - AL - TSum | ASPRest]) :-		% call with N = 1
	N =< NP,
	generatePersonASP(N, ASA, AL, TSum),
	N1 is N + 1,
	generateASP(NP, N1, ASA, ASPRest).
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
constraintASAMembers(NP, [ANum | ALNumsRest], [ANum - N | ASA]) :-
	N #:: 1..NP,
	constraintASAMembers(NP, ALNumsRest, ASA).

constraintASA(NP, AL, ASA) :-
	ALLen is length(AL),
	length(ALNums, ALLen),
	ALNums #:: 1..ALLen,
	alldifferent(ALNums),
	constraintASAMembers(NP, ALNums, ASA).

listlistTimeCheck([]).
listlistTimeCheck([A | NL]) :-
	activity(A, act(AStart, AEnd)),
	listTimeCheck(NL, AStart, AEnd),
	listlistTimeCheck(NL).

% pair-wise checking?

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
