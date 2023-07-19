import os
import sys

import fastapi
import uvicorn

app = fastapi.FastAPI()


@app.get('/ping')
def ping():
    return {'ping': 'ok'}


@app.post('/die')
def die():
    os._exit(1)

if __name__ == '__main__':
    print(f'{sys.argv=}')
    uvicorn.run(app, host='0.0.0.0', port=8889)
