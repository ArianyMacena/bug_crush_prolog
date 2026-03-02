:- module(logic, [make_move/5, resolve_board/2, resolve_silent/2]).
:- use_module(library(clpfd)).
:- use_module('config.pl').
:- use_module('board.pl').
:- use_module('render.pl').

direction_delta(w,-1,0).
direction_delta(s, 1,0).
direction_delta(a,0,-1).
direction_delta(d,0, 1).

make_move(Board,R,C,Dir,NewBoard) :-
    direction_delta(Dir,DR,DC),
    R2 is R+DR,
    C2 is C+DC,
    valid_pos(R2,C2),
    swap(Board,R,C,R2,C2,NewBoard).

is_match(Board, R, C) :-
    cell(Board, R, C, V), V \== nil,
    (
        (C1 is C-1, C2 is C-2, cell(Board, R, C1, V), cell(Board, R, C2, V)) ;
        (C1 is C-1, C2 is C+1, cell(Board, R, C1, V), cell(Board, R, C2, V)) ;
        (C1 is C+1, C2 is C+2, cell(Board, R, C1, V), cell(Board, R, C2, V)) ;
        (R1 is R-1, R2 is R-2, cell(Board, R1, C, V), cell(Board, R2, C, V)) ;
        (R1 is R-1, R2 is R+1, cell(Board, R1, C, V), cell(Board, R2, C, V)) ;
        (R1 is R+1, R2 is R+2, cell(Board, R1, C, V), cell(Board, R2, C, V))
    ).

clear_board(Board, NewBoard) :-
    size(N),
    findall(Row, (
        between(1, N, R),
        findall(Cell, (
            between(1, N, C),
            (is_match(Board, R, C) -> Cell = nil ; cell(Board, R, C, Cell))
        ), Row)
    ), NewBoard).

% === GRAVIDADE ===

fall_col([X, nil | T], [nil, X | T]) :- X \== nil.
fall_col([H | T], [H | T1]) :- fall_col(T, T1).
fall_col([nil | T], [Bug | T]) :- random_bug(Bug).
fall_step(Col, NextCol) :- fall_col(Col, NextCol), !.
fall_step(Col, Col).

apply_gravity_step(Board, NextBoard) :-
    transpose(Board, Cols),
    maplist(fall_step, Cols, NextCols),
    transpose(NextCols, NextBoard).

animate_gravity(Board, FinalBoard) :-
    apply_gravity_step(Board, NextBoard),
    ( Board \== NextBoard ->
        render(NextBoard), sleep(0.3),
        animate_gravity(NextBoard, FinalBoard)
    ; FinalBoard = Board ).
    
resolve_board(Board, FinalBoard) :-
    clear_board(Board, Cleared),
    ( Board \== Cleared ->
        render(Cleared), write("Matches encontrados!"), nl, sleep(0.8),
        animate_gravity(Cleared, Fallen),
        resolve_board(Fallen, FinalBoard)
    ; FinalBoard = Board ).

% === CONFIGURANDO A EXIBIÇÃO PRA SÓ ACONTECER QUANDO O TABULEIRO ESTIVER PRONTO ===

gravity_col_instant(Col, NewCol) :-
    include(\==(nil), Col, Solid),
    length(Col, N),
    length(Solid, S),
    Missing is N - S,
    length(Pad, Missing),
    maplist({}/[X]>>random_bug(X), Pad),
    append(Pad, Solid, NewCol).

% Resolve cascatas 
resolve_silent(Board, FinalBoard) :-
    clear_board(Board, Cleared),
    ( Board \== Cleared ->
        transpose(Cleared, Cols),
        maplist(gravity_col_instant, Cols, NewCols),
        transpose(NewCols, Fallen),
        resolve_silent(Fallen, FinalBoard)
    ; FinalBoard = Board ).