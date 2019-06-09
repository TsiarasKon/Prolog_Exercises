:- lib(ic).
:- lib(branch_and_bound).

assignment_opt(NF, NP, ST, F, T, ASP, ASA, Cost) :-
	getAL(NF, ALun),
	insert_sort(ALun, AL),
	calcD(AL, D),
	calcA(NP, D, A),
	ALLen is length(AL),
	length(ASAN, ALLen),
	ASAN #:: 1..NP,
	length(Ws, NP),
	Ws #:: 0..ST,
	calcWs(AL, AL, ASAN, ASAN, ST, 1, Ws),
	constraintASAN(AL, AL, ASAN, ASAN, NP, 1, -1),
	Cost #:: 0..NP*A^2,
	calcCost(Ws, A, Cost),
	bb_min(labeling(ASAN), Cost, bb_options{delta:F, timeout:T}),
	% bb_min(labeling(ASAN), Cost, bb_options{delta:F, timeout:T, strategy:dichotomic}),
	generateASA(AL, ASAN, ASAun),
	sort(ASAun, ASA),
	generateASP(ASA, Ws, 1, ASP).

getAL(0, AL) :-
	findall((A, AStart, AEnd), activity(A, act(AStart, AEnd)), AL).
getAL(NF, ALNF) :-
	NF > 0,
	findall((A, AStart, AEnd), activity(A, act(AStart, AEnd)), AL),
	length(ALNF, NF),
	append(ALNF, _, AL).

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
	[PrevLatestN, NextLatestN] #:: -1..108,
	(AN #= N, PrevLatestN #< AStart, NextLatestN #= AEnd) or (AN #\= N, NextLatestN #= PrevLatestN),
	constraintASAN(AL, ALRest, ASAN, ASANRest, NP, N, NextLatestN).

generateASA([], [], []).
generateASA([(A, _, _) | ALRest], [N | ASANRest], [A - N | ASARest]) :-
	generateASA(ALRest, ASANRest, ASARest).

generatePersonAL([], _, []).
generatePersonAL([A - N | ASARest], N, [A | ALRest]) :-
	generatePersonAL(ASARest, N, ALRest).
generatePersonAL([_ - NOther | ASARest], N, AL) :-
	NOther \= N,
	generatePersonAL(ASARest, N, AL).

generateASP(_, [], _, []).
generateASP(ASA, [Wi | WRest], N, [N - ALN - Wi | ASPRest]) :-
	generatePersonAL(ASA, N, ALN),
	N1 is N + 1,
	generateASP(ASA, WRest, N1, ASPRest).

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
	NRest is length(WsRest),
	Cost1 #:: 0..NRest*A^2,
	calcCost(WsRest, A, Cost1),
	CurrCost #:: 0..A^2,
	CurrCost #= (A - Wi) ^ 2,
	Cost #= CurrCost + Cost1.

%%%%%%

activity(a001, act(41,49)).
activity(a002, act(72,73)).
activity(a003, act(80,85)).
activity(a004, act(65,74)).
activity(a005, act(96,101)).
activity(a006, act(49,55)).
activity(a007, act(51,59)).
activity(a008, act(63,65)).
activity(a009, act(66,69)).
activity(a010, act(80,87)).
activity(a011, act(71,76)).
activity(a012, act(64,68)).
activity(a013, act(90,93)).
activity(a014, act(49,56)).
activity(a015, act(23,29)).
activity(a016, act(94,101)).
activity(a017, act(25,34)).
activity(a018, act(51,54)).
activity(a019, act(13,23)).
activity(a020, act(67,72)).
activity(a021, act(19,21)).
activity(a022, act(12,16)).
activity(a023, act(99,104)).
activity(a024, act(92,94)).
activity(a025, act(74,83)).
activity(a026, act(95,100)).
activity(a027, act(39,47)).
activity(a028, act(39,49)).
activity(a029, act(37,39)).
activity(a030, act(57,66)).
activity(a031, act(95,101)).
activity(a032, act(71,74)).
activity(a033, act(86,93)).
activity(a034, act(51,54)).
activity(a035, act(74,83)).
activity(a036, act(75,81)).
activity(a037, act(33,43)).
activity(a038, act(29,30)).
activity(a039, act(58,60)).
activity(a040, act(52,61)).
activity(a041, act(35,39)).
activity(a042, act(46,51)).
activity(a043, act(71,72)).
activity(a044, act(17,24)).
activity(a045, act(94,103)).
activity(a046, act(77,87)).
activity(a047, act(83,87)).
activity(a048, act(83,92)).
activity(a049, act(59,62)).
activity(a050, act(2,4)).
activity(a051, act(86,92)).
activity(a052, act(94,103)).
activity(a053, act(80,81)).
activity(a054, act(39,46)).
activity(a055, act(60,67)).
activity(a056, act(72,78)).
activity(a057, act(58,61)).
activity(a058, act(8,18)).
activity(a059, act(12,16)).
activity(a060, act(47,50)).
activity(a061, act(49,50)).
activity(a062, act(71,78)).
activity(a063, act(34,42)).
activity(a064, act(21,26)).
activity(a065, act(92,95)).
activity(a066, act(80,81)).
activity(a067, act(74,79)).
activity(a068, act(28,29)).
activity(a069, act(100,102)).
activity(a070, act(29,37)).
activity(a071, act(4,12)).
activity(a072, act(79,83)).
activity(a073, act(98,108)).
activity(a074, act(91,100)).
activity(a075, act(82,91)).
activity(a076, act(59,66)).
activity(a077, act(34,35)).
activity(a078, act(51,60)).
activity(a079, act(92,94)).
activity(a080, act(77,83)).
activity(a081, act(38,48)).
activity(a082, act(51,59)).
activity(a083, act(35,39)).
activity(a084, act(22,24)).
activity(a085, act(67,68)).
activity(a086, act(90,97)).
activity(a087, act(82,83)).
activity(a088, act(51,53)).
activity(a089, act(78,88)).
activity(a090, act(74,79)).
activity(a091, act(100,105)).
activity(a092, act(53,63)).
activity(a093, act(57,66)).
activity(a094, act(32,41)).
activity(a095, act(48,56)).
activity(a096, act(92,96)).
activity(a097, act(4,8)).
activity(a098, act(31,33)).
activity(a099, act(69,77)).
activity(a100, act(88,93)).
