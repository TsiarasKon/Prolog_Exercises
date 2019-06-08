:- lib(ic).
:- lib(branch_and_bound).

% activity(a1, act(0,3)).
% activity(a2, act(4,6)).
% activity(a3, act(1,2)).

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

% assignment_opt(0, 3, 14, _, _, Ws, ASAN, Cost).

insert_sort(List, Sorted) :- 
	i_sort(List, [], Sorted).
i_sort([], Acc, Acc).
i_sort([(A, AStart, AEnd) | T], Acc, Sorted) :- 
	insert((A, AStart, AEnd), Acc, NAcc), i_sort(T, NAcc, Sorted).
   
insert((A1, AStart1, AEnd1), [(A2, AStart2, AEnd2) | T], [(A2, AStart2, AEnd2) | NT]) :-
	AStart1 > AStart2,
	insert((A1, AStart1, AEnd1), T, NT).
insert((A1, AStart1, AEnd1), [(A2, AStart2, AEnd2) | T], [(A1, AStart1, AEnd1), (A2, AStart2, AEnd2) | T]) :-
	AStart1 =< AStart2.
insert((A, AStart, AEnd), [], [(A, AStart, AEnd)]).

assignment_opt(NF, NP, ST, F, T, ASP, ASA, Cost) :-
	NF == 0,
	findall((A, AStart, AEnd), activity(A, act(AStart, AEnd)), ALun),
	insert_sort(ALun, AL),
	calcD(AL, D),
	calcA(NP, D, A),
	ALLen is length(AL),
	length(ASAN, ALLen),
	ASAN #:: 1..NP,
	constraintASAN(AL, AL, ASAN, ASAN, NP, 1, -1),
	length(Ws, NP),
	Ws #:: 0..ST,
	calcWs(AL, AL, ASAN, ASAN, 1, Ws),
	calcCost(Ws, A, Cost),
	bb_min(labeling(ASAN), Cost, _),
	generateASA(AL, ASAN, ASAun),
	sort(ASAun, ASA),
	generateASP(ASA, Ws, 1, ASP).

calcWs(_, _, _, _, _, []).
calcWs(AL, [], ASAN, [], N, [0 | WsRest]) :-
	N1 is N + 1,
	calcWs(AL, AL, ASAN, ASAN, N1, WsRest).
calcWs(AL, [(_, AStart, AEnd) | ALRest], ASAN, [AN | ASANRest], N, [WiNew | WsRest]) :-
	(AN #= N, WiNew #= Wi + AEnd - AStart) or (AN #\= N, WiNew #= Wi),
	calcWs(AL, ALRest, ASAN, ASANRest, N, [Wi | WsRest]).


constraintASAN(_, _, _, _, NP, N, _) :-
	N > NP, !.
constraintASAN(AL, [], ASAN, [], NP, N, _) :-
	% N =< NP,
	N1 is N + 1,
	constraintASAN(AL, AL, ASAN, ASAN, NP, N1, -1).
constraintASAN(AL, [(_, AStart, AEnd) | ALRest], ASAN, [AN | ASANRest], NP, N, PrevLatestN) :-
	% N =< NP,
	(AN #= N, PrevLatestN #< AStart, NextLatestN #= AEnd) or (AN #\= N, NextLatestN #= PrevLatestN),
	constraintASAN(AL, ALRest, ASAN, ASANRest, NP, N, NextLatestN).

generateASA([], [], []).
generateASA([(A, _, _) | ALRest], [N | ASANRest], [A - N | ASARest]) :-
	generateASA(ALRest, ASANRest, ASARest).

generatePersonAL([], _, []).
generatePersonAL([A - N | ASARest], N, [A | ALRest]) :-
	generatePersonAL(ASARest, N, ALRest).
generatePersonAL([A - NOther | ASARest], N, AL) :-
	NOther \= N,
	generatePersonAL(ASARest, N, AL).

generateASP(_, [], _, []).
generateASP(ASA, [Wi | WRest], N, [N - ALN - Wi | ASPRest]) :-
	generatePersonAL(ASA, N, ALNrev),
	reverse(ALNrev, ALN),
	N1 is N + 1,
	generateASP(ASA, WRest, N1, ASPRest).

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

calcD([], 0).
calcD([(A, AStart, AEnd) | ALRest], D) :-
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
