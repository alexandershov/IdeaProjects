import argparse
import asyncio


async def handle_echo(reader, writer):
    while True:
        data = await reader.read(-1)
        if not data:
            break
        writer.write(data)
        await writer.drain()

    writer.close()


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--port", type=int)
    return parser.parse_args()


def main():
    args = parse_args()
    asyncio.run(start_server(args))


async def start_server(args):
    server = await asyncio.start_server(
        handle_echo, '127.0.0.1', args.port)
    async with server:
        await server.serve_forever()


if __name__ == '__main__':
    main()
