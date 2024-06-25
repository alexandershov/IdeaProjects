import argparse
import asyncio
import time

import matplotlib.pyplot as plt


async def download(args):
    reader, _ = await asyncio.open_connection(
        args.host, args.port)
    started_at = time.time()
    received = 0
    stats = {}

    def save_stats():
        nonlocal received
        duration = time.time() - started_at
        stats[duration] = received / duration
        asyncio.get_event_loop().call_later(0.01, save_stats)

    asyncio.get_event_loop().call_later(0, save_stats)
    while received < args.max_bytes:
        data = await reader.read(1000)
        received += len(data)

    plt.plot(list(stats.keys()), list(stats.values()))
    plt.xlabel('time (seconds)')
    plt.ylabel('speed (bytes/second)')
    plt.show()


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--host', default='127.0.0.1')
    parser.add_argument('--port', type=int, default=8080)
    parser.add_argument('--max-bytes', type=int, default=10_000_000)
    return parser.parse_args()


def main():
    args = parse_args()
    asyncio.run(download(args))


if __name__ == '__main__':
    main()
