from fastapi import FastAPI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_openai import ChatOpenAI
# install langserve with `pip install "langserve[all]"`
from langserve import add_routes

# this is the same as langchain.ipynb but as a service
system_template = "answer the questions as if you're {character}"
user_template = "{text}"

prompt_template = ChatPromptTemplate.from_messages([
    ("system", system_template), ("user", user_template)])

model = ChatOpenAI()
parser = StrOutputParser()
chain = prompt_template | model | parser


app = FastAPI(
    title="LangChain Server",
    version="1.0",
    description="A simple API server using LangChain's Runnable interfaces",
)

add_routes(
    app,
    chain,
    path="/chain",
)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="localhost", port=8000)