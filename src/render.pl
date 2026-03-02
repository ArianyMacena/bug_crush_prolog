:- module(render, [render/1]).
:- use_module('config.pl').

draw_board(Board) :-
    draw_rows(Board, 1).

draw_rows([], _).
draw_rows([Row|Rest], I) :-
    format("~d ", [I]),
    draw_row(Row),
    nl,
    I2 is I+1,
    draw_rows(Rest, I2).

draw_row([]).
draw_row([Cell|Rest]) :-
    ansi_color(Cell, Symbol),
    write(Symbol), write(" "),
    draw_row(Rest).

draw_header :-
    size(N),
    write("  "),
    forall(between(1,N,C), format("~d ", [C])),
    nl.

render(Board) :-
    draw_header,
    draw_board(Board).