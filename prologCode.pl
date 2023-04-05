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
removeCard(Card, [Card|Rest], Rest).
removeCard(Card, [Other|Rest], [Other|NewRest]) :- 
    removeCard(Card, Rest, NewRest).
matches(card(c1,c11), card(c2, c22)) :- 
    c1=c2, c11=c22.
addToDiscardPile(Card, DiscardPile, [Card|DiscardPile]).
isWild(Card) :- 
    Card = card(_,wild);Card= card(_,wild_draw4).
setTopCard(TopCard, DiscardPile, [TopCard|Rest]) :- 
    removeCard(TopCard, DiscardPile, Rest).
isEmpty([]).
setWinner(Player1, _, Player2, Player1) :- 
    isEmpty(Player2).
setWinner(_, _, Player2, Player2).

evaluateCard((card(a,b)), CurrentPlayer, (card(topa,topb)), Value) :-
        true.
