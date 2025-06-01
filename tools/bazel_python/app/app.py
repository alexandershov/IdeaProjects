import fastapi
import uvicorn

# TODO: understand why this import works (why `app` directory is in path)?
from app import add

app = fastapi.FastAPI()


@app.get("/add")
def add_endpoint(x: int, y: int):
    return {"result": add.add(x, y)}


if __name__ == '__main__':
    uvicorn.run(app)
