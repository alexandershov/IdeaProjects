# this is a fastapi+graphql playground
# run this file (python fastapi_app.py) and go to http://127.0.0.1:8000/graphql
# graphql is just a query language independent of data source
# you add data sources (e.g. database, microservice, etc) using resolvers

import datetime as dt
import os
from typing import Annotated, List, Optional

import asyncpg
import strawberry
import uvicorn
import fastapi
from fastapi import FastAPI, Depends, Request, Response
from fastapi import responses
from pydantic import BaseModel
from strawberry.fastapi import GraphQLRouter
from strawberry.types import Info
from fastapi import templating

templates = templating.Jinja2Templates(directory='templates')


class Date:
    def __init__(self, s):
        self.value = dt.date.fromisoformat(s)

    def render(self):
        return self.value.isoformat()


# Define data model
class Message(BaseModel):
    id: str
    body: str


@strawberry.experimental.pydantic.type(model=Message, all_fields=True)
class GraphqlMessage:
    pass


async def fetch_messages(info: Info, cursor: str = None):
    # `cursor` can be passed from graphql:
    # {
    #   messages(cursor: "test") {
    #     id
    #     body
    #   }
    # }
    # or using variables:
    # query MessageWithVar($cursor: String!) {
    #   messages(cursor: $cursor) {
    #     id
    #     body
    #   }
    # }
    # you will need to pass variables: {"cursor": "abc"}
    # also see intellij_http_client.http for examples of graphql queries
    print(f'{cursor=}')
    print(f'{info.variable_values=}')
    async with pool.acquire() as conn:
        rows = await conn.fetch("SELECT id, body FROM messages")
        return [GraphqlMessage(id=row['id'], body=row['body']) for row in rows]


@strawberry.type
class Messages:
    messages: list[GraphqlMessage] = strawberry.field(resolver=fetch_messages)


schema = strawberry.Schema(Messages)
graphql_app = GraphQLRouter(schema)

app = FastAPI()
app.include_router(graphql_app, prefix="/graphql")

# Database connection details
database_name = "notes"

# Create a connection pool
pool: Optional[asyncpg.Pool] = None


async def get_date(request: Request):
    body = await request.body()
    return Date(body.decode('utf-8'))


class DateResponse(Response):
    def render(self, content):
        print(f"{content}")
        return content.render().encode('utf-8')


@app.post("/next_day", response_class=DateResponse)
async def next_day(date: Annotated[Date, Depends(get_date)]) -> DateResponse:
    date.value += dt.timedelta(days=1)
    return DateResponse(date)


@app.on_event("startup")
async def startup():
    global pool
    pool = await asyncpg.create_pool(user=os.getenv('DB_USER'),
                                     port=os.getenv('DB_PORT'),
                                     database=database_name,
                                     host=os.getenv('DB_HOST'))


@app.on_event("shutdown")
async def shutdown():
    await pool.close()


async def get_conn() -> asyncpg.Connection:
    async with pool.acquire() as connection:
        yield connection


@app.get('/messages', response_model=List[Message])
async def get_messages(conn: asyncpg.Connection = Depends(get_conn)):
    rows = await conn.fetch('SELECT id, body FROM messages')
    return [Message(id=row['id'], body=row['body']) for row in rows]


@app.get('/htmx', response_class=responses.HTMLResponse)
async def htmx(request: fastapi.Request, conn: asyncpg.Connection = Depends(get_conn)):
    rows = await conn.fetch('SELECT id, body FROM messages')
    messages = [Message(id=row['id'], body=row['body']) for row in rows]
    return templates.TemplateResponse('htmx_root.html', {'request': request, 'messages': messages})


@app.get('/htmx/messages/edit/{message_id}', response_class=responses.HTMLResponse)
async def htmx_edit_message(request: fastapi.Request, message_id: str, conn: asyncpg.Connection = Depends(get_conn)):
    rows = await conn.fetch('SELECT id, body FROM messages WHERE id = $1', message_id)
    messages = [Message(id=row['id'], body=row['body']) for row in rows]
    assert len(messages) == 1
    return templates.TemplateResponse('htmx_edit_message.html', {'request': request, 'message': messages[0]})


@app.post('/htmx/messages/edit/{message_id}', response_class=responses.HTMLResponse)
async def htmx_edit_message(request: fastapi.Request, message_id: str, body: str = fastapi.Form(...),
                            conn: asyncpg.Connection = Depends(get_conn)):
    rows = await conn.fetch('UPDATE messages SET body = $1 WHERE id = $2 RETURNING *', body, message_id)
    messages = [Message(id=row['id'], body=row['body']) for row in rows]
    assert len(messages) == 1
    return templates.TemplateResponse('htmx_message.html', {'request': request, 'message': messages[0]})


if __name__ == '__main__':
    uvicorn.run("fastapi_app:app", reload=True, host='0.0.0.0')
