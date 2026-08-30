import asyncio
import os

import uvicorn
from fastapi import FastAPI

app = FastAPI()


@app.get("/sleep")
async def sleep(duration: float):
    await asyncio.sleep(duration)
    return {"slept": duration}


if __name__ == '__main__':
    print(f"{os.getpid()=}")
    uvicorn.run(app)
