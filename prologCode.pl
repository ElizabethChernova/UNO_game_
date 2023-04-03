deck(Cards) :-
    findall(card(Color, Value), (color(Color), value(Value)), Cards).

    
shuffle([], []).
shuffle(List, Shuffled) :-
    length(List, Length),
    random_permutation(List, Shuffled),
    length(Shuffled, Length).
    
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

nextPlayer(NextPlayer, [NextPlayer,Player2], Player2).
nextPlayer(NextPlayer, [Player1,NextPlayer], Player1).

    
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

% Card deck
card(0, 0). % zero
card(0, 1). % zero
card(1, 0). % one
card(1, 1). % one
card(2, 0). % two
card(2, 1). % two
card(3, 0). % three
card(3, 1). % three
card(4, 0). % four
card(4, 1). % four
card(5, 0). % five
card(5, 1). % five
card(6, 0). % six
card(6, 1). % six
card(7, 0). % seven
card(7, 1). % seven
card(8, 0). % eight
card(8, 1). % eight
card(9, 0). % nine
card(9, 1). % nine
card(draw2, 2). % draw two
card(reverse, 2). % reverse
card(skip, 2). % skip
card(wild, 4). % wild
card(wild_draw4, 4). % wild draw 
