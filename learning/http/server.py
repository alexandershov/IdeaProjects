import json

from fastapi import FastAPI
import uvicorn
from starlette.responses import StreamingResponse

app = FastAPI()


@app.get("/health_chunked")
async def health_chunk():
    async def generator():
        for _ in range(3):
            yield json.dumps({"healthy": "ok"})

    return StreamingResponse(generator())


@app.get("/health")
def health_check():
    return {"healthy": "ok"}


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
