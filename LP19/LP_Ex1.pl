% disnake([a,b,c,d,e,f,g], [_,_,_,_,_,_,_,_,_,_,_], [_,_,_,_,_,_]).
% disnake([0,1,2,3,4,5,6,7,8,9], [_,_,_,_], [_,_,_]).
 

write_list([]).
write_list([X | List]) :-
	write(X),
	write_list(List).
	
write_grid([]).
write_grid([R1 | RRest]) :-
	write_list(R1),
	write('\n'),
	write_grid(RRest).
	
my_prepend(L1, L2, L3) :-
	append(L2, L1, L3).

/*	
disnake(Pattern, _, [_ | List]) :- 
	writelist(Pattern),
	write('\n'),
	disnake(Pattern, _, List).

disnake(Pattern, L1, L2) :- disnakebool(Pattern, L1, L2, true).

disnakebool(Pattern, _, [_ | List], true) :-
	writelist(Pattern),
	write('\n'),
	disnakebool(Pattern, _, List, false).
	
disnakebool(Pattern, _, [_ | List], false) :-
	reverse(Pattern, Revpattern),
	writelist(Revpattern),
	write('\n'),
	disnakebool(Pattern, _, List, true).
	


disnake(Pattern, Cols, Rows) :-
	disnakehelper(Pattern, Cols, Rows, Pattern, Cols).
	
disnakehelper(Pattern, Cols, Rows, [P1 | PRest], [_ | CRest]) :-
	write(P1),
	disnakehelper(Pattern, Cols, Rows, PRest, CRest).
	
disnakehelper(Pattern, Cols, Rows, [], C) :-
	disnakehelper(Pattern, Cols, Rows, Pattern, C).
	
disnakehelper(Pattern, Cols, [_ | RRest], P, []) :-
	write('\n'),
	disnakehelper(Pattern, Cols, RRest, P, Cols).

*/

disnake(Pattern, Cols, Rows) :-
	disnakehelper(Pattern, Cols, Rows, Pattern, Cols, [[]]).
	
disnakehelper(Pattern, Cols, Rows, [P1 | PRest], [_ | CRest], [G1 | GRest]) :-
	append(G1, [P1], NewG1),
	disnakehelper(Pattern, Cols, Rows, PRest, CRest, [NewG1 | GRest]).
	
disnakehelper(Pattern, Cols, Rows, [], C, Grid) :-
	disnakehelper(Pattern, Cols, Rows, Pattern, C, Grid).
	
disnakehelper(Pattern, Cols, [_ | RRest], P, [], Grid) :-
	my_prepend(Grid, [[]], NewGrid),
	disnakehelper(Pattern, Cols, RRest, P, Cols, NewGrid).
	
disnakehelper(_, _, [], _, [], Grid) :-
	reverse(Grid, GridRev),
	write_grid(GridRev).
	
	
	
	