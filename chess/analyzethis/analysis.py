import asyncio
import json
import os
import pathlib

import dotenv
import httpx


async def download_games(lichess_user_name: str, lichess_api_token: str, max: int, output: pathlib.Path) -> None:
    with output.open("w") as fileobj:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"https://lichess.org/api/games/user/{lichess_user_name}",
                params={"max": max, "pgnInJson": "true"},
                headers={
                    "Accept": "application/x-ndjson",
                    "Authorization": f"Bearer {lichess_api_token}"
                })
            async for line in response.aiter_lines():
                pgn = json.loads(line)["pgn"]
                fileobj.write(pgn)


async def amain():
    dotenv.load_dotenv()
    lichess_api_token = os.environ["LICHESS_API_TOKEN"]
    lichess_user_name = os.environ["LICHESS_USER_NAME"]
    output = pathlib.Path(f"{lichess_user_name}-games.pgn")
    await download_games(lichess_user_name, lichess_api_token, 5, output)


if __name__ == '__main__':
    asyncio.run(amain())
