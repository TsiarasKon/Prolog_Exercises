frogs(0, 0, []).
frogs(N, M, Solution) :-
	create_list('g', N, GList),
	create_list('b', M, BList),
	append(GList, [' '], NewGList),
	append(NewGList, BList, InitialState),
	append(BList, [' '], NewBList),
	append(NewBList, GList, FinalState),
	solve(InitialState, FinalState, [InitialState], Solution).
	
create_list(_, 0, []).
create_list(X, N, L) :-
	length(L, N),
	maplist(=(X), L).
	
solve(FinalState, FinalState, _, []).
solve(CurrentState, FinalState, States, [Move|Solution]) :-
	CurrentState \= FinalState,
	move(CurrentState, NextState, Move),
	not(member(NextState, States)),
	solve(NextState, FinalState, [NextState|States], Solution).
	
move(['g', ' ', 'b'|Rest], [' ', 'g', 'b'|Rest], "g1").
move(['b', 'g', ' '|Rest], ['b', ' ', 'g'|Rest], "g1").
move(['g', 'b', ' '|Rest], [' ', 'b', 'g'|Rest], "g2").
move(['g', ' ', 'b'|Rest], ['g', 'b', ' '|Rest], "b1").
move([' ', 'b', 'g'|Rest], ['b', ' ', 'g'|Rest], "b1").
move([' ', 'g', 'b'|Rest], ['b', 'g', ' '|Rest], "b2").
move([X, Y, Z|Rest], [X|NextState], Res) :-
	move([Y, Z|Rest], NextState, Res).