deck(Cards) :-
    findall(card(Color, Value), (color(Color), value(Value)), Cards).

    
shuffle([], []).
shuffle(List, Shuffled) :-
    length(List, Length),
    random_permutation(List, Shuffled),
    length(Shuffled, Length).

findAllValidMoves(PlayerCards, card(TopColor, TopValue), ValidMoves) :-
    findall(card(Color, Value), (
         member(card(Color, Value), PlayerCards),
    (Value = wild ; Value = wild_draw4 ;(Value= TopValue, Color\= TopColor); (Color= TopColor)) 
    ), ValidMoves).
hasValidMove(PlayerCards, card(TopColor, TopValue)) :-
    member(card(Color, Value), PlayerCards),
    (Value = wild ; Value = wild_draw4 ; Value= TopValue ; Color= TopColor).

color(red).
color(yellow).
color(green).
color(blue).

value(0).
value(1).
value(2).
value(3).
value(4).
value(5).
value(6).
value(7).
value(8).
value(9).
value(draw2).
value(reverse).
value(skip).
value(wild).
value(wild_draw4).
nextPlayer(NextPlayer, [NextPlayer,Player2], Player2).
nextPlayer(NextPlayer, [Player1,NextPlayer], Player1).

% Deal cards to players
dealCards([], _, _, []).
dealCards([Player|Players], Cards, N, [PlayerCards|PlayerHands]) :-
    length(PlayerCards, N),
    append(PlayerCards, RestCards, Cards),
    dealCards(Players, RestCards, N, PlayerHands).
% Deal cards to players
deal_cards(Deck, [Hand1, Hand2], DrawPile) :-
    split_deck(Deck, Hand1Cards, Hand2Cards, DrawPileCards),
    Hand1 = hand(Hand1Cards),
    Hand2 = hand(Hand2Cards),
    DrawPile = draw_pile(DrawPileCards).





