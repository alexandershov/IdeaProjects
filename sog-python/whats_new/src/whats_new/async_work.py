import asyncio
import os


async def awork():
    await asyncio.sleep(0.1)
    work()


def work():
    len([] * 100000)


async def amain():
    pid = os.getpid()
    print(f"{pid=}")
    for _ in range(1000):
        await awork()


if __name__ == '__main__':
    asyncio.run(amain())
