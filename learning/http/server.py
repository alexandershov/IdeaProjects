import json

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


@app.get("/health")
def health_check():
    return {"healthy": "ok"}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
