import aiohttp
import temporalio.activity

from temporal_data import Params


@temporalio.activity.defn
async def messages_activity(params: Params) -> str:
    print(f'executing messages_activity: {params=}')
    async with aiohttp.client.ClientSession() as session:
        async with session.get(params.url) as resp:
            text = await resp.text()
            print(f'{params.message=} {text=}')
            return text
