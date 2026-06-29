import {Chessground} from './vendor/chessground/chessground.min.js';

const boardElement = document.getElementById('board');

Chessground(boardElement, {
    coordinates: true,

    movable: {
        free: true,
        color: 'both',

        events: {
            // callback after each move
            after: async (orig, dest) => {
                const response = await fetch('/move', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({orig, dest}),
                });

                console.log(await response.json());
            },
        },
    },
});