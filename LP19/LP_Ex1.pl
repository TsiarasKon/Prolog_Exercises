% disnake([a,b,c,d,e,f,g], [_,_,_,_,_,_,_,_,_,_,_], [_,_,_,_,_,_]).
 
/*
writelist([]).
writelist([X | List]) :-
	write(X),
	writelist(List).

	
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
	
*/

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
