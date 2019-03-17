% Delet these:
/*
activity(a01, act(0,3)).
activity(a02, act(0,4)).
activity(a03, act(1,5)).
activity(a04, act(4,6)).
activity(a05, act(6,8)).
activity(a06, act(6,9)).
activity(a07, act(9,10)).
activity(a08, act(9,13)).
activity(a09, act(11,14)).
activity(a10, act(12,15)).
activity(a11, act(14,17)).
activity(a12, act(16,18)).
activity(a13, act(17,19)).
activity(a14, act(18,20)).
activity(a15, act(19,20)).
*/

activity(a1, act(0,3)).
activity(a2, act(4,6)).
activity(a3, act(1,2)).


assignment(NP, ST, ASP, ASA) :-
	findall(A, activity(A, act(_, _)), AL),
	createStartingASP(NP, StartingASP),
	assignmentHelper(ST, RevASP, ASA, StartingASP, AL),
	reverse(RevASP, ASP).

createStartingASP(0, []).
createStartingASP(N, [N - [] - 0 | ASPRest]) :-
	N > 0,
	N1 is N - 1,
	createStartingASP(N1, ASPRest).
	
assignmentHelper(_, ASP, [], ASP, []).
assignmentHelper(ST, ASP, [A - N | ASARest], ASPBefore, [A | ALRest]) :-
	assignActivity(A, ST, ASPBefore, ASPAfter, N),
	assignmentHelper(ST, ASP, ASARest, ASPAfter, ALRest).
	
/*
assignActivity(A, ST, ASPBefore, ASPAfter, N) :-
	append(ASP1, [N - [] - 0 | ASP2], ASPBefore),
	activity(A, act(AStart, AEnd)),
	TSum1 is AEnd - AStart,
	TSum1 =< ST,
	append(ASP1, [N - [A] - TSum1 | ASP2], ASPAfter).

assignActivity(A, ST, ASPBefore, ASPAfter, N) :-
	append(ASP1, [N - [LastA | NL] - TSum | ASP2], ASPBefore),
	activity(A, act(AStart, AEnd)),
	activity(LastA, act(_, LastAEnd)),
	MinStartT is LastAEnd + 1,
	AStart >= MinStartT,
	TSum1 is TSum + AEnd - AStart,
	TSum1 =< ST,
	append(ASP1, [N - [A, LastA | NL] - TSum1 | ASP2], ASPAfter).
*/

assignActivity(A, ST, ASPBefore, ASPAfter, N) :-
	append(ASP1, [N - NL - TSum | ASP2], ASPBefore),
	activity(A, act(AStart, AEnd)),
	canBeAssigned(AStart, AEnd, N, ASPBefore),
	TSum1 is TSum + AEnd - AStart,
	TSum1 =< ST,
	append(ASP1, [N - [A | NL] - TSum1 | ASP2], ASPAfter).
	
canBeAssigned(AStart, AEnd, N, ASP) :-
	member(N - NL - _, ASP),
	listTimeCheck(NL, AStart, AEnd).
	
listTimeCheck([], _, _).
listTimeCheck([PastA | NL], AStart, AEnd) :-
	activity(PastA, act(PastAStart, PastAEnd)),
	(AEnd < PastAStart; AStart > PastAEnd),
	listTimeCheck(NL, AStart, AEnd).
