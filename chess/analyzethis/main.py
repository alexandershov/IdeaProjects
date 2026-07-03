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
from fastapi import FastAPI, Request
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
def analyze_fen(fen: str):
    board = chess.Board(fen)
    with chess.engine.SimpleEngine.popen_uci(os.environ["ENGINE"]) as engine:
        analysis = engine.analyse(board, chess.engine.Limit(depth=16))
        float_score = analysis['score'].white().score() / 100
        if float_score > 0:
            return "+" + str(float_score)
        else:
            return float_score


if __name__ == "__main__":
    # load .env file into environment
    dotenv.load_dotenv()
    uvicorn.run('__main__:app', reload=True)
