import argparse
import asyncio


async def tcp_echo_client(args):
    reader, writer = await asyncio.open_connection(
        '127.0.0.1', args.port)
    writer.write(args.message.encode())
    writer.close()
    await writer.wait_closed()


def parse_args():
    parser = argparse.ArgumentParser(description="TCP Echo client")
    parser.add_argument('message', help='The message to be sent')
    parser.add_argument('--port', type=int, default=8888)
    return parser.parse_args()


def main():
    args = parse_args()
    asyncio.run(tcp_echo_client(args))


if __name__ == '__main__':
    main()
