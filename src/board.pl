:- module(board, [random_bug/1, generate_row/2, generate_board/2, init_board/1, cell/4, valid_pos/2, replace/4, set_cell/5, swap/6]).
:- use_module(library(random)).
:- use_module('config.pl').

random_bug(Bug) :-
    bug_types(Types),
    random_member(Bug, Types).

generate_row(N, Row) :-
    length(Row, N),
    maplist({}/[X]>>random_bug(X), Row).

generate_board(N, Board) :-
    length(Board, N),
    maplist(generate_row(N), Board).

init_board(Board) :-
    size(N),
    generate_board(N, Board).

valid_pos(R,C) :-
    size(N),
    R>=1, R=<N,
    C>=1, C=<N.

cell(Board,R,C,Val) :-
    valid_pos(R,C),
    nth1(R,Board,Row),
    nth1(C,Row,Val).

replace([_|T],1,X,[X|T]).
replace([H|T],I,X,[H|R]) :-
    I>1,
    I1 is I-1,
    replace(T,I1,X,R).

set_cell(Board,R,C,Val,NewBoard) :-
    nth1(R,Board,Row),
    replace(Row,C,Val,NewRow),
    replace(Board,R,NewRow,NewBoard).

swap(Board,R1,C1,R2,C2,NewBoard) :-
    cell(Board,R1,C1,V1),
    cell(Board,R2,C2,V2),
    set_cell(Board,R1,C1,V2,B1),
    set_cell(B1,R2,C2,V1,NewBoard).