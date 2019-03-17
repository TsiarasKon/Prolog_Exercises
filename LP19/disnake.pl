% Useful list predicates:

my_append([], L, L).
my_append([X | L1], L2, [X | L]) :-
	my_append(L1, L2, L).

my_reversehelper([], L, L).
my_reversehelper([X | LRest], SoFar, L) :-
	my_reversehelper(LRest, [X | SoFar], L).
	
my_reverse(L, LRev) :-
	my_reversehelper(L, [], LRev).

my_prepend(L1, L2, L3) :-
	my_append(L2, L1, L3).


% Useful printing predicates:

write_list([]).
write_list([X | List]) :-
	write(X),
	write_list(List).
	
write_grid([]).
write_grid([R1 | RRest]) :-
	write_list(R1),
	write('\n'),
	write_grid(RRest).


% disnake:

disnake(Pattern, Cols, Rows) :-
	disnakehelper(Pattern, Cols, Rows, Pattern, Cols, forward, [[]]).
	
change_direction(forward, backward).
change_direction(backward, forward).
	
disnakehelper(Pattern, Cols, [R1 | RRest], [P1 | PRest], [_ | CRest], forward, [G1 | GRest]) :-
	my_append(G1, [P1], NewG1),
	disnakehelper(Pattern, Cols, [R1 | RRest], PRest, CRest, forward, [NewG1 | GRest]).	
	
disnakehelper(Pattern, Cols, [R1 | RRest], [P1 | PRest], [_ | CRest], backward, [G1 | GRest]) :-
	my_prepend(G1, [P1], NewG1),
	disnakehelper(Pattern, Cols, [R1 | RRest], PRest, CRest, backward, [NewG1 | GRest]).
	
disnakehelper(Pattern, Cols, Rows, [], C, Direction, Grid) :-
	disnakehelper(Pattern, Cols, Rows, Pattern, C, Direction, Grid).
	
disnakehelper(Pattern, Cols, [_, R2 | RRest], P, [], Direction, Grid) :-
	my_prepend(Grid, [[]], NewGrid),
	change_direction(Direction, NewDirection),
	disnakehelper(Pattern, Cols, [R2 | RRest], P, Cols, NewDirection, NewGrid).
	
disnakehelper(_, _, [_], _, [], _, Grid) :-
	my_reverse(Grid, GridRev),
	write_grid(GridRev).
