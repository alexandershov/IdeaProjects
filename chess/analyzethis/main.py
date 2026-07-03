import itertools
import pathlib
from dataclasses import dataclass

import io
import chess.engine
import chess.pgn
import dotenv
import httpx
import json
import os
import uvicorn
from fastapi import FastAPI, Request, Response
from fastapi.staticfiles import StaticFiles
from fastapi import templating

templates = templating.Jinja2Templates(directory='templates')

app = FastAPI()
app.mount("/frontend", StaticFiles(directory="frontend", html=True), name="static")

@dataclass(frozen=True)
class MoveRequest:
    orig: str
    dest: str


@app.post("/move")
async def move(request: MoveRequest):
    return {"from": "server", "orig": request.orig, "dest": request.dest}


@app.get("/games")
async def download_games(request: Request, max: int = 5):
    lichess_api_token = os.environ["LICHESS_API_TOKEN"]
    lichess_user_name = os.environ["LICHESS_USER_NAME"]
    games = []
    pgn = (pathlib.Path(__file__).parent / "game.pgn").read_text()
    game = chess.pgn.read_game(io.StringIO(pgn))
    games.append(game)
    # async with httpx.AsyncClient() as client:
    #     response = await client.get(
    #         f"https://lichess.org/api/games/user/{lichess_user_name}",
    #         params={"max": max, "pgnInJson": "true"},
    #         headers={
    #             "Accept": "application/x-ndjson",
    #             "Authorization": f"Bearer {lichess_api_token}"
    #         })
    #     async for line in response.aiter_lines():
    #         pgn = json.loads(line)["pgn"]
    #         game = chess.pgn.read_game(io.StringIO(pgn))
    #         games.append(game)
    return templates.TemplateResponse(request=request, name="games.html", context={
        "games": games, "board": chess.Board()})

@app.get("/analyze/fen/")
def analyze_fen(fen: str, request: Request):
    board = chess.Board(fen)
    with chess.engine.SimpleEngine.popen_uci(os.environ["ENGINE"]) as engine:
        analysis = engine.analyse(board, chess.engine.Limit(depth=16))
        cp_score = analysis['score'].white().score()
        return templates.TemplateResponse(request=request, name="eval.html", context={"cp_score": cp_score})


@app.get("/analyze/pgn")
def analyze_pgn(pgn: str, request: Request) -> Response:
    # TODO: take pgn & pov from the parameters
    pgn = (pathlib.Path(__file__).parent / "game.pgn").read_text()
    pov = chess.BLACK
    game = chess.pgn.read_game(io.StringIO(pgn))
    move_order = itertools.cycle([chess.WHITE, chess.BLACK])
    # TODO: is there an async version of chess.engine.SimpleEngine?
    with chess.engine.SimpleEngine.popen_uci(os.environ["ENGINE"]) as engine:
        messages = []
        board = game.board()
        for i, move in enumerate(game.mainline_moves(), start=2):
            cur_player = next(move_order)
            if cur_player == pov:
                before_analysis = engine.analyse(board, chess.engine.Limit(depth=14))
                # TODO: unhardcode white
                before_score = before_analysis['score'].white().score()
                board.push(move)
                # TODO: unhardcode white
                after_analysis = engine.analyse(board, chess.engine.Limit(depth=14))
                after_score = after_analysis['score'].white().score()
                if before_score is None or after_score is None:
                    # TODO: handle mates (this is when scores are None)
                    continue
                loss = after_score - before_score
                print(f"{loss=}")
                # 0.5 pawn loss
                if loss >= 50:
                    messages.append(f"{i // 2}. {move.uci()} was an error with the {loss=}. " 
                                    f"best move was {before_analysis['pv'][0].uci()}")
            else:
                board.push(move)
        return templates.TemplateResponse(
            request=request, name="analysis.html", context={"messages": messages}
        )

if __name__ == "__main__":
    # load .env file into environment
    dotenv.load_dotenv()
    uvicorn.run('__main__:app', reload=True)
