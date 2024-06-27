import asyncio
import datetime as dt
import json
from typing import Optional

from fastapi import FastAPI, Request
import uvicorn
from starlette.responses import StreamingResponse

app = FastAPI()


@app.get("/chunked_response")
async def health_chunk():
    async def generator():
        for _ in range(3):
            yield json.dumps({"healthy": "ok"})

    return StreamingResponse(generator())


@app.post("/chunked_request")
async def streaming(request: Request):
    i = 0
    parts = []
    async for data in request.stream():
        print(f"got {data=}")
        ascii_data = data.decode('ascii')
        parts.append(f"[{i}] {ascii_data}")
        i += 1

    return {"parts": parts}


@app.get("/slow")
async def slow(delay: Optional[float] = 1):
    started_at = dt.datetime.now(tz=dt.UTC)
    await asyncio.sleep(delay)
    finished_at = dt.datetime.now(tz=dt.UTC)
    return {"delay": delay, started_at: started_at.isoformat(), "finished_at": finished_at.isoformat()}


@app.get("/health")
def health_check():
    return {"healthy": "ok"}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
