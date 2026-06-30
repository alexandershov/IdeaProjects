from dataclasses import dataclass

import dotenv
import uvicorn
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

app = FastAPI()
app.mount("/frontend", StaticFiles(directory="frontend", html=True), name="static")


@dataclass(frozen=True)
class MoveRequest:
    orig: str
    dest: str


@app.post("/move")
async def move(request: MoveRequest):
    return {"from": "server", "orig": request.orig, "dest": request.dest}


if __name__ == "__main__":
    # load .env file into environment
    dotenv.load_dotenv()
    uvicorn.run('__main__:app', reload=True)
