# analyzethis

## What is it?
Chess analytics project

## Creation
On backend this project was created with:

```shell
uv init analyzethis --vcs none
cd analyzethis
uv add fastapi uvicorn
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


