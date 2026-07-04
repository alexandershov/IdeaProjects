import argparse
import asyncio
import json
import os
import pathlib

import dotenv
import httpx


async def download_games(args) -> None:
    dotenv.load_dotenv()
    lichess_api_token = os.environ["LICHESS_API_TOKEN"]
    lichess_user_name = os.environ["LICHESS_USER_NAME"]
    with args.output.open("w") as fileobj:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                f"https://lichess.org/api/games/user/{lichess_user_name}",
                params={"max": args.max, "pgnInJson": "true"},
                headers={
                    "Accept": "application/x-ndjson",
                    "Authorization": f"Bearer {lichess_api_token}"
                })
            async for line in response.aiter_lines():
                pgn = json.loads(line)["pgn"]
                fileobj.write(pgn)


async def analyze_games(args):
    raise RuntimeError("not implemented yet")


def parse_args():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(required=True)
    download_parser = subparsers.add_parser("download")
    download_parser.add_argument("--max", type=int, default=5)
    download_parser.add_argument("--output", default='/dev/stdout', type=pathlib.Path)
    download_parser.set_defaults(func=download_games)

    analysis_parser = subparsers.add_parser("analysis")
    analysis_parser.add_argument("pgn")
    analysis_parser.set_defaults(func=analyze_games)
    return parser.parse_args()


async def amain():
    args = parse_args()
    await args.func(args)


if __name__ == '__main__':
    asyncio.run(amain())
