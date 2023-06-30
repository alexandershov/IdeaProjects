import trio


async def sleep_and_say(seconds: float):
    try:
        await trio.sleep(seconds)
    except trio.Cancelled:
        print(f'{seconds:.2f} seconds was cancelled')
        raise
    print(f'{seconds:.2f} seconds')


async def main():
    # with trio, you can't spawn orphan tasks
    # sleep_and_say tasks will be awaited in nursery
    async with trio.open_nursery() as nursery:
        nursery.start_soon(sleep_and_say, 0.2)
        nursery.start_soon(sleep_and_say, 0.1)

    print("we'll get here after sleep_and_say finish")

    async with trio.open_nursery() as nursery:
        with trio.move_on_after(0.05):
            await sleep_and_say(0.11)
            # we will never get here, sleep_and_say will be cancelled
            print('success!')
        print('moved on')


if __name__ == '__main__':
    trio.run(main)
