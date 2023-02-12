// Load the Prolog code into JsLog
// const pl = require('swi-prolog');
// //const Prolog = require('C:/Users/Liza/WebstormProjects/UNO_game_html/swipl/swipl/library/http/web/js/pengines.js');
// const engine = pl.create();
// engine.consult("prologCode.pl");
 const engine = new Prolog.Engine();
 engine.loadFile("prologCode.pl");


const deck = document.getElementById("deck");
const discardPile = document.getElementById("discard-pile");
const player1Hand = document.getElementById("player-1-hand");
const player2Hand = document.getElementById("player-2-hand");

deck.addEventListener("click", drawCard);
player1Hand.addEventListener("click", playCard);

function drawCard() {
    // Call the Prolog draw_card/3 predicate
    engine.query("draw_card(Deck, DrawnCard, NewDeck).",
        {
            success: function (query) {
                const result = query.answer;
                const deck = result.Deck;
                const drawnCard = result.DrawnCard;
                const newDeck = result.NewDeck;

                // Update the game state in JavaScript based on the Prolog results
                deck.innerHTML = newDeck.length;
                player1Hand.innerHTML += `<div class="card">${drawnCard}</div>`;
            },
            error: function (error) {
                console.error(error);
            }
        });
}

function playCard() {
    // Call the Prolog play_card/2 predicate
    engine.query("play_card(PlayerNo, Card).",
        {
            success: function (query) {
                const result = query.answer;
                const playerNo = result.PlayerNo;
                const card = result.Card;

                // Update the game state in JavaScript based on the Prolog results
                if (playerNo === 1) {
                    player1Hand.innerHTML = player1Hand.innerHTML.replace(`<div class="card">${card}</div>`, "");
                } else if (playerNo === 2) {
                    player2Hand.innerHTML = player2Hand.innerHTML.replace(`<div class="card">${card}</div>`, "");
                }
                discardPile.innerHTML = `<div class="card">${card}</div>`;
            },
            error: function (error) {
                console.error(error);
            }
        });
}