## HTTP

HTTP is HyperText Transfer Protocol that is used to Transfer way more things than just HyperText.

Run http server on port 8080
```shell
python server.py
```

HTTP/1.1 is pretty simple protocol,
First line is `METHOD /path protocol`, e.g. `GET /health HTTP/1.1`
Then we have header lines `HeaderName: HeaderValue`
In HTTP/1.1 only `Host` header is required.
Then empty line and optional request body.
All lines are ending with `\r\n` (carriage return + newline)


```shell
# -c so newline becomes `\r\n`
nc -c localhost 8000
GET /health HTTP/1.1
Host: localhost

HTTP/1.1 200 OK
date: Tue, 25 Jun 2024 18:08:06 GMT
server: uvicorn
content-length: 16
content-type: application/json

{"healthy":"ok"}
```

First line of response is `protocol status_code desc`, e.g. `HTTP/1.1 200 OK`.
Then headers and response body.

### Keep-Alive
In HTTP/1.1 keep-alive is default behaviour. This means that after you make a request and
receive a response TCP connection is not closed. It's open for some time. In uvicorn it's open for 5 seconds by default.
This can be changed by passing `timeout_keep_alive` in `uvicorn.run`
In theory you can specify timeout in your request with `Keep-Alive` header.
But for some reason that doesn't work with uvicorn:

```shell
nc -c localhost 8000
GET /health HTTP/1.1
Host: localhost
Keep-Alive: timeout=3

```

If you don't want keep-alive (that's strange since reusing TCP connections is good:
you save on TCP handshake and TCP slow start), then pass `Connection: close`

```shell
nc -c localhost 8000
GET /health HTTP/1.1
Host: localhost
Connection: close

HTTP/1.1 200 OK
date: Tue, 25 Jun 2024 18:45:36 GMT
server: uvicorn
content-length: 16
content-type: application/json
connection: close

{"healthy":"ok"}
# connection is immediately closed
```

### Chunked encoding
With chunked encoding you can stream responses:

```shell
nc -c localhost 8000
GET /chunked HTTP/1.1
Host: localhost

HTTP/1.1 200 OK
date: Tue, 25 Jun 2024 18:47:13 GMT
server: uvicorn
transfer-encoding: chunked

11
{"healthy": "ok"}
11
{"healthy": "ok"}
11
{"healthy": "ok"}
0

```
Response has header "transfer-encoding: chunked".
And then it's <chunk_length>\r\n<chunk_data>\r\n...
Last chunk has length 0.
Attention: for some reason chunk_length is in hex. E.g. content-length is decimal.

Both client and server can play this game, client can also send chunked request:

```shell
POST /chunked_request HTTP/1.1
host: localhost
transfer-encoding: chunked

2
ab
3
abc
0

HTTP/1.1 200 OK
date: Wed, 26 Jun 2024 19:27:02 GMT
server: uvicorn
content-length: 37
content-type: application/json

{"parts":["[0] ab","[1] abc","[2] "]}
```

Encoding rules are the same for request.