/* Create a list depiction of the initial state of the problem 
 * (e.g. ['g', 'g', 'g', 'g', ' ', 'b', 'b', 'b'] for N == 4 and M == 3)
 * and return the list of moves that, if applied to it, would yield 
 * its final state (['b', 'b', 'b', ' ', 'g', 'g', 'g', 'g'] for that same
 * example) using solve/2 */

frogs(0, 0, []).
frogs(N, M, Solution) :-
	create_list('g', N, GList),
	create_list('b', M, BList),
	append(GList, [' '], NewGList),
	append(NewGList, BList, InitialState),
	append(BList, [' '], NewBList),
	append(NewBList, GList, FinalState),
	solve(InitialState, FinalState, [InitialState], Solution).
	
/* Creates a list consisting of exactly N Xs. */
create_list(_, 0, []).
create_list(X, N, L) :-	
	length(L, N),
	maplist(=(X), L).

/* Returns a list of moves from a CurrentState to the FinalState
 * using move/3, without making moves that would result in a state
 * that we've already been before. */
solve(FinalState, FinalState, _, []).
solve(CurrentState, FinalState, States, [Move|Solution]) :-
	CurrentState \= FinalState,
	move(CurrentState, NextState, Move),
	not(member(NextState, States)),
	solve(NextState, FinalState, [NextState|States], Solution).
	
/* All possible moves are explicitly described here: */
move(['g', ' ', 'b'|Rest], [' ', 'g', 'b'|Rest], "g1").
move(['b', 'g', ' '|Rest], ['b', ' ', 'g'|Rest], "g1").
move(['g', 'b', ' '|Rest], [' ', 'b', 'g'|Rest], "g2").
move(['g', ' ', 'b'|Rest], ['g', 'b', ' '|Rest], "b1").
move([' ', 'b', 'g'|Rest], ['b', ' ', 'g'|Rest], "b1").
move([' ', 'g', 'b'|Rest], ['b', 'g', ' '|Rest], "b2").
move([X, Y, Z|Rest], [X|NextState], Res) :-
	move([Y, Z|Rest], NextState, Res).