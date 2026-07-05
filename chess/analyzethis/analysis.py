import argparse
import asyncio
import collections
import datetime as dt
import itertools
import json
import os
import pathlib
import sys
import urllib.parse

import chess.engine
import chess.pgn
import chess.polyglot
import dotenv
import httpx

NUM_ANALYZED_GAMES = 0


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
    with open(args.input) as fileobj:
        queue = asyncio.Queue()
        mistakes = collections.defaultdict(list)
        workers = [asyncio.create_task(analysis_worker(queue, args, mistakes)) for _ in range(args.workers)]
        i = 0
        while i < args.max:
            game = chess.pgn.read_game(fileobj)
            if game is None:
                break
            await queue.put(game)
            i += 1
    queue.shutdown()
    await queue.join()
    await asyncio.gather(*workers)
    print("counts of common mistakes", file=sys.stderr)
    print(json.dumps({fen: [m.uci() for m in moves] for fen, moves in mistakes.items() if len(moves) >= 2}),
          file=sys.stderr)


async def analyze_one_game(engine: chess.engine.Protocol, game: chess.pgn.Game, player: str, args, mistakes):
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
            before_fen = board.fen()
            before_analysis = await engine.analyse(board, chess.engine.Limit(depth=args.depth))
            expectation_before = before_analysis['score'].wdl().pov(cur_color).expectation()
            board.push(move)
            after_analysis = await engine.analyse(board, chess.engine.Limit(depth=args.depth))
            expectation_after = after_analysis['score'].wdl().pov(cur_color).expectation()
            loss = expectation_before - expectation_after
            if loss >= 0.2:
                mistakes[before_fen].append(move)
                messages.append(f"{move_number}. {move.uci()} was an error with the expectation {loss=:.2f}. "
                                f"best move was {before_analysis['pv'][0].uci()}")
        else:
            board.push(move)
    return "\n".join(messages)


def _is_clowning_around(board: chess.Board, moves) -> bool:
    """detect knight dance and bongcloud"""
    moves = set(moves)
    if board.fullmove_number <= 3:
        return True
    if moves == {"g8f6"} or moves == {"f6g8"} or moves == {"b8c6"} or moves == {"c6b8"}:
        return True
    if moves == {"g1f3"} or moves == {"f3g1"} or moves == {"b1c3"} or moves == {"c3b1"}:
        return True
    if board.fullmove_number == 2 and (moves == {"e1e2"} or moves == "e8e7"):
        return True
    return False


def _exclude_theory(reader: chess.polyglot.MemoryMappedReader, board: chess.Board, moves: list[str]) -> list[str]:
    not_theoretical_moves = []
    for a_move in moves:
        move = chess.Move.from_uci(a_move)
        board_copy = chess.Board(board.fen())
        board_copy.push(move)
        if reader.get(board) is None:
            not_theoretical_moves.append(a_move)
    return not_theoretical_moves


async def summarize(args):
    with chess.polyglot.open_reader("gm2600.bin") as reader:
        mistakes = json.loads(args.analysis.read_text())
        filtered_mistakes = {}
        for fen, moves in mistakes.items():
            board = chess.Board(fen)
            if _is_clowning_around(board, moves):
                continue
            not_theoretical_moves = _exclude_theory(reader, board, moves)
            if not not_theoretical_moves:
                continue
            filtered_mistakes[fen] = [f"https://lichess.org/analysis/fromPosition/{urllib.parse.quote(fen)}", not_theoretical_moves]
        print(json.dumps(filtered_mistakes, indent=2))


async def analysis_worker(queue: asyncio.Queue, args, counts):
    transport, engine = await chess.engine.popen_uci(os.environ["ENGINE"])
    while True:
        try:
            game: chess.pgn.Game = await queue.get()
        except asyncio.QueueShutDown:
            break
        verdict = await analyze_one_game(engine, game, os.environ["LICHESS_USER_NAME"], args, counts)
        if verdict:
            game_id = game.headers["GameId"]
            print(f"analysis of game https://lichess.org/{game_id}\n{verdict}")
        global NUM_ANALYZED_GAMES
        NUM_ANALYZED_GAMES += 1
        print(f"analyzed {NUM_ANALYZED_GAMES} games")
        queue.task_done()


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
    analysis_parser.add_argument("--workers", type=int, default=12)
    analysis_parser.add_argument("--max-move", type=int, default=float('inf'))
    analysis_parser.set_defaults(func=analyze_games)

    # parser to summarize result of analysis
    summarise_parser = subparsers.add_parser("summarize")
    summarise_parser.add_argument("analysis", type=pathlib.Path)
    summarise_parser.set_defaults(func=summarize)
    return parser.parse_args()


async def amain():
    args = parse_args()
    dotenv.load_dotenv()
    await args.func(args)


if __name__ == '__main__':
    asyncio.run(amain())
