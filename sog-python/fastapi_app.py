# this is a fastapi+graphql playground
# run this file (python fastapi_app.py) and go to http://127.0.0.1:8000/graphql
# graphql is just a query language independent of data source
# you add data sources (e.g. database, microservice, etc) using resolvers

import os
from typing import List, Optional

import asyncpg
import strawberry
import uvicorn
from fastapi import FastAPI, Depends
from pydantic import BaseModel
from strawberry.fastapi import GraphQLRouter
from strawberry.types import Info


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


@app.get("/messages", response_model=List[Message])
async def get_messages(conn: asyncpg.Connection = Depends(get_conn)):
    rows = await conn.fetch("SELECT id, body FROM messages")
    return [Message(id=row['id'], body=row['body']) for row in rows]


if __name__ == '__main__':
    uvicorn.run("fastapi_app:app", reload=True, host='0.0.0.0')
