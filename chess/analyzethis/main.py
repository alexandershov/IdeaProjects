import uvicorn
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

app = FastAPI()
app.mount("/", StaticFiles(directory="frontend", html=True), name="static")


@app.get("/")
def index():
    return {"status": "ok"}




if __name__ == "__main__":
    uvicorn.run(app)
