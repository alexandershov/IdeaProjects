# analyzethis

## What is it?
Chess analytics project

## Creation
On backend this project was created with:

```shell
uv init analyzethis --vcs none
cd analyzethis
uv add fastapi uvicorn chess python-dotenv httpx ...
```

On frontend this project was created with:
```shell
npm create vite@latest frontend -- --template vanilla
cd frontend
npm install
npm install @lichess-org/chessground
mkdir vendor
cp -r node_modules/@lichess-org/chessground/assets/ vendor/chessground
cp node_modules/@lichess-org/chessground/dist/chessground.min.js vendor/chessground
```

Chessground is chess board that is used in lichess.

You need to get lichess API token from https://lichess.org/account/oauth/token.
Put it to `.env` file as `LICHESS_API_TOKEN`

Run the project with 
```shell
uv run main.py
```

and go to http://127.0.0.1:8000
