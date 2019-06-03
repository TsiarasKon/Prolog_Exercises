activity(a1, act(0,3)).
activity(a2, act(4,6)).
activity(a3, act(1,2)).

assignment(NF, NP, ST, ASP, ASA) :-
	NF == 0,
	findall(A, activity(A, act(_, _)), AL),
	createStartingASP(NP, StartingASP),
	assignmentHelper(ST, RevASP, ASA, StartingASP, AL),
	reverse(RevASP, ASP).

assignment(NF, NP, ST, ASP, ASA) :-
	NF > 0,
	findall(A, activity(A, act(_, _)), AL),
	createStartingASP(NP, StartingASP),
	length(ALNF, NF),
	append(ALNF, _, AL),
	assignmentHelper(ST, RevASP, ASA, StartingASP, ALNF),
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
	(AEnd < PastAStart; AStart > PastAEnd),
	listTimeCheck(NL, AStart, AEnd).
