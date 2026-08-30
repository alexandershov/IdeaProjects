import asyncio
import pdb


async def async_add(x, y):
    await asyncio.sleep(1)
    return x + y


async def amain():
    await async_add(1, 2)
    # with set_trace_async we can use await in the debugger!
    # although for some reason it doesn't print the returned value of await statement:
    # (Pdb) await async_add(1, 2)
    # > /Users/aershov/IdeaProjects/sog-python/whats_new/src/whats_new/async_debugging.py(12)amain()
    await pdb.set_trace_async()


if __name__ == '__main__':
    asyncio.run(amain())
