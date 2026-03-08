:- module(main, [start/0]).
:- encoding(utf8).
:- use_module(library(readutil)).
:- use_module('board.pl').
:- use_module('render.pl').
:- use_module('logic.pl').
:- use_module('ui.pl').

menu_loop :-
    main_menu(Opcao),
    process_menu(Opcao).

process_menu(1) :-
    login_screen(Name),
    init_board(Board),
    resolve_silent(Board, ReadyBoard),
    game_loop(ReadyBoard, Name, 0, 15).

process_menu(2) :-
    rules_screen,
    menu_loop.

process_menu(3) :-
    instructions_screen,
    menu_loop.

process_menu(4) :-
    writeln('Saindo do jogo... Bye Bye!!'), halt.

process_menu(_) :-
    writeln('Entrada inválida! Por favor, escolha entre 1, 2, 3, ou 4.'),
    menu_loop.


read_number(Prompt, Num) :-
    write(Prompt), flush_output(current_output),
    read_line_to_string(user_input, Input),
    (   number_string(ParsedNum, Input)
    ->  Num = ParsedNum
    ;   writeln('Entrada inválida! Por favor, digite apenas números.'),
        read_number(Prompt, Num)
    ).

read_direction(Prompt, Dir) :-
    write(Prompt), flush_output(current_output),
    read_line_to_string(user_input, Input),
    string_lower(Input, Lower),
    (   member(Lower, ["w", "a", "s", "d"])
    ->  atom_string(Dir, Lower)
    ;   writeln('Direção inválida! Use apenas w, a, s, ou d.'),
        read_direction(Prompt, Dir)
    ).

read_move(R,C,D) :-
    read_number('Linha: ', R),
    read_number('Coluna: ', C),
    read_direction('Dir (w/a/s/d): ', D),
    nl.


game_loop(_, Name, Points, Movements) :-
    (Points >= 500 ; Movements =< 0),
    !,
    game_over_screen(Name, Points),
    menu_loop.

game_loop(Board, Name, Points, Movements) :-
    clear_screen,
    render_hud(Name, Points, Movements),
    render(Board),
    read_move(R,C,D),
    (
        make_move(Board,R,C,D,Next)
    ->
        % Mostra o tabuleiro logo apos a troca manual do jogador
        clear_screen,
        render_hud(Name, Points, Movements),
        render(Next), 
        write("Trocando peças..."), 
        sleep(0.8),
        
        % Inicia a verificacao de matches e quedas
        resolve_board(Next, ResolvedBoard, GainedPoints),

        NewPoints is Points + GainedPoints,
        NewMovements is Movements - 1,

        write("Pontos ganhos: "), 
        writeln(GainedPoints), 
        sleep(1.0),

        game_loop(ResolvedBoard, Name, NewPoints, NewMovements)
    ;
        write("Movimento inválido! Pressione [Enter] para tentar de novo."),
        read_line_to_string(user_input, _),
        game_loop(Board, Name, Points, Movements)
    ).

start :-
    initial_screen,
    menu_loop.