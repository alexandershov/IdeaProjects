import asyncio
import datetime as dt
import itertools
import json
import pathlib
from typing import Optional, Annotated

from fastapi import FastAPI, Request, Response, Header
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


@app.get("/server_sent_events")
def server_sent_events():
    content = pathlib.Path("server_sent_events.html").read_text()
    return Response(content=content, media_type="text/html")


@app.get("/stream_server_sent_events")
async def stream_server_sent_events(start: int, last_event_id: Annotated[Optional[int], Header()] = None):
    print(f"{last_event_id=}")

    async def event_stream():
        for i in itertools.count(last_event_id or start):
            yield f"id: {i}\n"
            yield f"data: {i * i}\n\n"
            await asyncio.sleep(1)

    return StreamingResponse(event_stream(), media_type="text/event-stream")


if __name__ == "__main__":
    uvicorn.run('server:app', host="0.0.0.0", port=8000, reload=True)
