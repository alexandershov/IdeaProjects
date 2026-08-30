# Async

## What is it
This document describes async features in the new-ish python versions.

## Usage
### ps & pstree

Since 3.14 asyncio can show running tasks (`asyncio ps`) or a task tree (`asyncio pstree`). 
Let's start some async app:
```shell
uv run src/whats_new/webapp.py
os.getpid()=58101
```

In another terminal:
```shell
# sudo so we can attach to process
sudo uv run -m asyncio ps 58101
tid        task id              task name            coroutine stack                                    awaiter chain                                      awaiter name    awaiter id
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
61779160   0x4ebacfc0210        Task-1               sleep -> Server.main_loop -> Server._serve -> Server.serve                                                                    0x0
61779160   0x4ebacfc0410        Task-2               Queue.get -> LifespanOn.receive -> Router.lifespan -> APIRouter.app -> Router.__call__ -> AsyncExitStackMiddleware.__call__ -> ExceptionMiddleware.__call__ -> ServerErrorMiddleware.__call__ -> Starlette.__call__ -> FastAPI.__call__ -> ProxyHeadersMiddleware.__call__ -> LifespanOn.main                                                                    0x0
61779160   0x4ebacfc0a10        Task-5               sleep -> sleep -> run_endpoint_function -> get_request_handler.<locals>.app -> request_response.<locals>.app.<locals>.app -> wrap_app_handling_exceptions.<locals>.wrapped_app -> request_response.<locals>.app -> Route.handle -> APIRoute.handle -> APIRouter.app -> Router.__call__ -> AsyncExitStackMiddleware.__call__ -> wrap_app_handling_exceptions.<locals>.wrapped_app -> ExceptionMiddleware.__call__ -> ServerErrorMiddleware.__call__ -> Starlette.__call__ -> FastAPI.__call__ -> ProxyHeadersMiddleware.__call__ -> RequestResponseCycle.run_asgi                                                                    0x0
➜  whats_new git:(main) ✗ sudo uv run -m asyncio pstree 58101
└── (T) Task-1
    └──  Server.serve /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/uvicorn/server.py:81
        └──  Server._serve /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/uvicorn/server.py:98
            └──  Server.main_loop /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/uvicorn/server.py:239
                └──  sleep /Users/aershov/.local/share/uv/python/cpython-3.15.0rc1+freethreaded-macos-aarch64-none/lib/python3.15t/asyncio/tasks.py:705
└── (T) Task-2
    └──  LifespanOn.main /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/uvicorn/lifespan/on.py:86
        └──  ProxyHeadersMiddleware.__call__ /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/uvicorn/middleware/proxy_headers.py:30
            └──  FastAPI.__call__ /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/fastapi/applications.py:1163
                └──  Starlette.__call__ /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/starlette/applications.py:96
                    └──  ServerErrorMiddleware.__call__ /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/starlette/middleware/errors.py:151
                        └──  ExceptionMiddleware.__call__ /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/starlette/middleware/exceptions.py:49
                            └──  AsyncExitStackMiddleware.__call__ /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/fastapi/middleware/asyncexitstack.py:18
                                └──  Router.__call__ /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/starlette/routing.py:670
                                    └──  APIRouter.app /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/fastapi/routing.py:2726
                                        └──  Router.lifespan /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/starlette/routing.py:655
                                            └──  LifespanOn.receive /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/uvicorn/lifespan/on.py:137
                                                └──  Queue.get /Users/aershov/.local/share/uv/python/cpython-3.15.0rc1+freethreaded-macos-aarch64-none/lib/python3.15t/asyncio/queues.py:186
└── (T) Task-5
    └──  RequestResponseCycle.run_asgi /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/uvicorn/protocols/http/h11_impl.py:416
        └──  ProxyHeadersMiddleware.__call__ /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/uvicorn/middleware/proxy_headers.py:63
            └──  FastAPI.__call__ /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/fastapi/applications.py:1163
                └──  Starlette.__call__ /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/starlette/applications.py:96
                    └──  ServerErrorMiddleware.__call__ /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/starlette/middleware/errors.py:164
                        └──  ExceptionMiddleware.__call__ /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/starlette/middleware/exceptions.py:63
                            └──  wrap_app_handling_exceptions.<locals>.wrapped_app /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/starlette/_exception_handler.py:42
                                └──  AsyncExitStackMiddleware.__call__ /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/fastapi/middleware/asyncexitstack.py:18
                                    └──  Router.__call__ /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/starlette/routing.py:670
                                        └──  APIRouter.app /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/fastapi/routing.py:2734
                                            └──  APIRoute.handle /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/fastapi/routing.py:1281
                                                └──  Route.handle /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/starlette/routing.py:280
                                                    └──  request_response.<locals>.app /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/fastapi/routing.py:158
                                                        └──  wrap_app_handling_exceptions.<locals>.wrapped_app /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/starlette/_exception_handler.py:42
                                                            └──  request_response.<locals>.app.<locals>.app /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/fastapi/routing.py:144
                                                                └──  get_request_handler.<locals>.app /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/fastapi/routing.py:706
                                                                    └──  run_endpoint_function /Users/aershov/IdeaProjects/sog-python/whats_new/.venv/lib/python3.15t/site-packages/fastapi/routing.py:352
                                                                        └──  sleep /Users/aershov/IdeaProjects/sog-python/whats_new/src/whats_new/webapp.py:12
                                                                            └──  sleep /Users/aershov/.local/share/uv/python/cpython-3.15.0rc1+freethreaded-macos-aarch64-none/lib/python3.15t/asyncio/tasks.py:705
```
