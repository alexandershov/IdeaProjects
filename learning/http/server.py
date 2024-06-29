import asyncio
import datetime as dt
import itertools
import json
import pathlib
from typing import Optional, Annotated

from fastapi import FastAPI, Request, Response, Header, WebSocketDisconnect
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import RedirectResponse
import uvicorn
from starlette.responses import StreamingResponse
from starlette.websockets import WebSocket

app = FastAPI()
app.add_middleware(GZipMiddleware, minimum_size=5)


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
def server_sent_events_page():
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


@app.get("/websockets")
def websockets_page():
    content = pathlib.Path("websockets.html").read_text()
    return Response(content=content, media_type="text/html")


@app.websocket("/websockets_stream")
async def websockets_stream(websocket: WebSocket):
    await websocket.accept()
    while True:
        # receive_text() receives a new message
        try:
            message = await websocket.receive_text()
            now = dt.datetime.now(tz=dt.UTC)
            # send_text() sends a new message
            await websocket.send_text(f"received {message} at {now.isoformat()}")
        except WebSocketDisconnect:
            print("disconnected")
            break


@app.get("/old/health")
def read_root():
    return RedirectResponse(url="/health/")


if __name__ == "__main__":
    uvicorn.run('server:app', host="0.0.0.0", port=8000, reload=True)
