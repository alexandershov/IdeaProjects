import argparse
import asyncio
import collections
import datetime as dt
import itertools
import json
import os
import pathlib
import sys

import chess.engine
import chess.pgn
import dotenv
import httpx


async def download_games(args) -> None:
    lichess_api_token = os.environ["LICHESS_API_TOKEN"]
    lichess_user_name = os.environ["LICHESS_USER_NAME"]
    with args.output.open("w") as fileobj:
        async with httpx.AsyncClient() as client:
            params = {
                "pgnInJson": "true",
            }
            if args.max is not None:
                params["max"] = str(args.max)
            if args.since is not None:
                params["since"] = str(int(args.since.timestamp() * 1000))
            response = await client.get(
                f"https://lichess.org/api/games/user/{lichess_user_name}",
                params=params,
                headers={
                    "Accept": "application/x-ndjson",
                    "Authorization": f"Bearer {lichess_api_token}"
                })
            num_saved_games = 0
            async for line in response.aiter_lines():
                pgn = json.loads(line)["pgn"]
                fileobj.write(pgn)
                num_saved_games += 1
                if num_saved_games % 10 == 0:
                    print(f"saved {num_saved_games} games", file=sys.stderr)


async def analyze_games(args):
    counts = collections.Counter()
    with open(args.input) as fileobj:
        transport, engine = await chess.engine.popen_uci(os.environ["ENGINE"])
        i = 0
        while i < args.max:
            game = chess.pgn.read_game(fileobj)
            if game is None:
                break
            verdict = await analyze_one_game(engine, game, os.environ["LICHESS_USER_NAME"], args, counts)
            i += 1
            print(f"analyzed {i} games", file=sys.stderr)
            if verdict:
                game_id = game.headers["GameId"]
                print(f"analysis of game http://lichess.org/{game_id}\n{verdict}")
    print(counts.most_common(10))


async def analyze_one_game(engine: chess.engine.Protocol, game: chess.pgn.Game, player: str, args, counts):
    assert game is not None
    player_by_color = {
        chess.WHITE: game.headers["White"],
        chess.BLACK: game.headers["Black"],
    }
    move_order = itertools.cycle([chess.WHITE, chess.BLACK])
    messages = []
    board = game.board()
    for i, move in enumerate(game.mainline_moves(), start=2):
        move_number = i // 2
        if move_number > args.max_move:
            break
        cur_color = next(move_order)
        if player_by_color[cur_color] == player:
            before_analysis = await engine.analyse(board, chess.engine.Limit(depth=args.depth))
            expectation_before = before_analysis['score'].wdl().pov(cur_color).expectation()
            board.push(move)
            after_analysis = await engine.analyse(board, chess.engine.Limit(depth=args.depth))
            expectation_after = after_analysis['score'].wdl().pov(cur_color).expectation()
            loss = expectation_before - expectation_after
            if loss >= 0.2:
                counts[board.fen()] += 1
                messages.append(f"{move_number}. {move.uci()} was an error with the expectation {loss=:.2f}. "
                                f"best move was {before_analysis['pv'][0].uci()}")
        else:
            board.push(move)
    return "\n".join(messages)


def parse_args():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(required=True)

    # parser to download games from lichess
    download_parser = subparsers.add_parser("download")
    download_parser.add_argument("--max", type=int)
    download_parser.add_argument("--since", type=dt.datetime.fromisoformat)
    download_parser.add_argument("--output", default='/dev/stdout', type=pathlib.Path)
    download_parser.set_defaults(func=download_games)

    # parser to analyze games from the local pgn file from the pov of the given player
    analysis_parser = subparsers.add_parser("analyze")
    analysis_parser.add_argument("input")
    analysis_parser.add_argument("--max", type=int, default=float('inf'))
    analysis_parser.add_argument("--depth", type=int, default=14)
    analysis_parser.add_argument("--max-move", type=int, default=float('inf'))
    analysis_parser.set_defaults(func=analyze_games)
    return parser.parse_args()


async def amain():
    args = parse_args()
    dotenv.load_dotenv()
    await args.func(args)


if __name__ == '__main__':
    asyncio.run(amain())
