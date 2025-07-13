import sys

import fastapi
import uvicorn
from rules_pie.greeter import hello

app = fastapi.FastAPI()


@app.get("/version")
def version():
    return hello(f"python {sys.version}")


if __name__ == '__main__':
    uvicorn.run(app, port=8888)
