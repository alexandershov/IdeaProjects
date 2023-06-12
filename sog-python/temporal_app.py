# how to run it:
# python fastapi_app.py
# temporal server start-dev
# python temporal_app.py
# python temporal_client.py
# this will start a workflow that initiates two requests to /messages endpoint
# in fastapi app

import asyncio
import datetime as dt
import temporalio.activity
import temporalio.client
import temporalio.workflow
import temporalio.worker

# workflows run in the sandbox, that's why we extract non-deterministic code
# to the activities
with temporalio.workflow.unsafe.imports_passed_through():
    from temporal_activities import messages_activity
from temporal_data import Params


@temporalio.activity.defn
async def wait_activity() -> None:
    print('executing wait_activity')
    await asyncio.sleep(10)


@temporalio.workflow.defn
class MessagesWorkflow:
    @temporalio.workflow.run
    async def run(self, params: Params):
        count = 2
        for i in range(count):
            result = await temporalio.workflow.execute_activity(
                messages_activity,
                params,
                start_to_close_timeout=dt.timedelta(seconds=10)
            )
            print(f'{i=} {result=}')
            is_last = (i == count - 1)
            if not is_last:
                await temporalio.workflow.execute_activity(
                    wait_activity,
                    start_to_close_timeout=dt.timedelta(seconds=11)
                )


async def main():
    client = await temporalio.client.Client.connect('localhost:7233')
    print('connected to temporal server')
    worker = temporalio.worker.Worker(
        client,
        task_queue='messages_queue',
        workflows=[MessagesWorkflow],
        activities=[messages_activity, wait_activity],
    )
    print('starting worker')
    await worker.run()


if __name__ == '__main__':
    asyncio.run(main())
