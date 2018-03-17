carpet(N) :-
	N1 is N - 1,
	rewrite(_, Carpet),
	carpet_help(Carpet, N1), !.
	
carpet_help(Carpet, 0) :- carpet_print(Carpet).
carpet_help(Carpet, N) :-
	N1 is N - 1,
	recarpet(Carpet, NewCarpet),
	carpet_help(NewCarpet, N1).

recarpet([], []).
recarpet([Row|Carpet], NewCarpet) :-
	expand_row(Row, NewRows),
	append(NewRows, PrevCarpet, NewCarpet),
	recarpet(Carpet, PrevCarpet).
	
expand_row([], []).
expand_row([X|Row], NewRows) :-
	rewrite(X, RL),
	expand_row(Row, SoFarRows),
	add_to(RL, SoFarRows, NewRows).

add_to([], [], []).
add_to(RL, [], RL).
add_to([R|RL], [SoFarR|SoFarRows], [NewR|NewRows]) :-
	append(R, SoFarR, NewR), 
	add_to(RL, SoFarRows, NewRows).
	
carpet_print([]).
carpet_print([Row|Carpet]) :-
	row_print(Row),
	print('\n'),
	carpet_print(Carpet).
	
row_print([]).
row_print([X|R]) :-
	print(X),
	row_print(R).