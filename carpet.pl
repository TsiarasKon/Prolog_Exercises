carpet(N) :-
	N1 is N - 1,
	rewrite(_, Carpet),	% carpet_help/2 is getting the list of lists of the first rewrite/2 found
	carpet_help(Carpet, N1), !.
	
/* While N > 0, apply a recarpet/2 and recursively call itself until N == 0.
 * After every call we're always left with a "2D matrix" (list of lists). */
carpet_help(Carpet, 0) :- carpet_print(Carpet).
carpet_help(Carpet, N) :-
	N1 is N - 1,
	recarpet(Carpet, NewCarpet),
	carpet_help(NewCarpet, N1).

/* Create a NewCarpet by "expanding" every row of the old carpet. */
recarpet([], []).
recarpet([Row|Carpet], NewCarpet) :-
	expand_row(Row, NewRows),
	append(NewRows, PrevCarpet, NewCarpet),
	recarpet(Carpet, PrevCarpet).
	
/* Apply rewrite to every char of Row and return a list of lists. */
expand_row([], []).
expand_row([X|Row], NewRows) :-
	rewrite(X, RL),
	expand_row(Row, SoFarRows),
	add_to(RL, SoFarRows, NewRows).

/* Used by expand_row/2 to gradually create the list of lists to be returned. */
add_to([], [], []).
add_to(RL, [], RL).
add_to([R|RL], [SoFarR|SoFarRows], [NewR|NewRows]) :-
	append(R, SoFarR, NewR), 
	add_to(RL, SoFarRows, NewRows).

/* Print every	row of carpet. */
carpet_print([]).	
carpet_print([Row|Carpet]) :-
	row_print(Row),
	write('\n'),
	carpet_print(Carpet).
	
/* Print every char of row. */
row_print([]).
row_print([X|R]) :-
	write(X),
	row_print(R).