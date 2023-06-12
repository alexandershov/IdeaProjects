import asyncio

import temporalio.client
from temporal_data import Params


async def main():
    client = await temporalio.client.Client.connect('localhost:7233')
    result = await client.execute_workflow(
        "MessagesWorkflow",
        Params('http://localhost:8000/messages', 'haha'),
        id='messages-workflow-1',
        task_queue='messages_queue',
    )
    print(f'{result=}')


if __name__ == '__main__':
    asyncio.run(main())
