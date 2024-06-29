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

### Redirects

Using redirects server can, ahem, redirect requests to a new location

```shell
nc -c localhost 8000
GET /old/health HTTP/1.1
host: localhost

HTTP/1.1 307 Temporary Redirect
date: Sat, 29 Jun 2024 16:36:12 GMT
server: uvicorn
content-length: 0
location: /health/
```

It uses 307 status code for redirect (there are other types of redirects that use different 30x status codes)
Redirect location is specified via `Location` header


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


### Pipelining

You can send requests without waiting for responses. This is called pipelining.
It's not properly supported in a lot of places.
E.g. uvicorn processes requests sequentially (look at started_at/finished_at values in responses, second response started
only after the first completed)
In theory with pipelining you can process requests in parallel.
You're still required to return responses in order of requests, so if only the first response is slow, then client
will get fast 2nd, 3rd responses after waiting for the first one. This is another variation on infamous head-of-line blocking.

```shell
nc -c localhost 8000
GET /slow?delay=2 HTTP/1.1
host: localhost

GET /slow?delay=1 HTTP/1.1
host: localhost


HTTP/1.1 200 OK
date: Thu, 27 Jun 2024 18:57:14 GMT
server: uvicorn
content-length: 132
content-type: application/json

{"delay":2.0,"2024-06-27T18:57:14.682339+00:00":"2024-06-27T18:57:14.682339+00:00","finished_at":"2024-06-27T18:57:16.683146+00:00"}
HTTP/1.1 200 OK
date: Thu, 27 Jun 2024 18:57:14 GMT
server: uvicorn
content-length: 132
content-type: application/json

{"delay":1.0,"2024-06-27T18:57:16.685386+00:00":"2024-06-27T18:57:16.685386+00:00","finished_at":"2024-06-27T18:57:17.686392+00:00"}
```

### Server-sent events
This is just a stream of message on top of HTTP/1.1 that has good support in a browser.
See [server_sent_events.html](./server_sent_events.html) for an example.
Format of messages is:
```
data: <any data>

data: <any data>
```
You can also add attributes `id:` and `event:` (event type).  

Start server:
```shell
python server.py
```

Then go to browser `http://localhost:8000/server_sent_events` and look at console.
You can stop server and js client will try to reconnect automatically, it will remember the last seen event id
and send it in a `Last-Event-ID` header. Cool stuff.

### Websockets
Websockets provide bidirectional stream of messages in browser. That's the closest you can get to raw tcp sockets.
Still websockets are not exactly tcp sockets.

Start server:
```shell
python server.py
```

Then go to browser `http://localhost:8000/websockets` and look at console.

Client side source for websockets is [here](./websockets.html).

Websockets connection uses HTTP/1.1 "Upgrade" feature, essentially you make a request with headers:
```text
Connection: Upgrade
Upgrade: websocket
```

Then server responds with 101 "Switching Protocols:
```text
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
```

and HTTP rules are gone, you're using custom protocol on a tcp connection at this point.

Running on top of http/https makes websockets http-proxy and http-infrastructure friendly.

Client sends Sec-WebSocket-Key header, server returns signed value of Sec-WebSocket-Key in a Sec-WebSocket-Accept
to prove that it understands the requested protocol version.

Relevant tcpdump logs:
```shell
sudo tcpdump -i lo0 -A tcp port 8000
...
GET /websockets_stream HTTP/1.1
Host: localhost:8000
Sec-WebSocket-Key: <secret>
Sec-Fetch-Site: same-origin
Sec-WebSocket-Version: 13
Sec-WebSocket-Extensions: permessage-deflate
Cache-Control: no-cache
Sec-Fetch-Mode: websocket
Origin: http://localhost:8000
Connection: Upgrade
Accept-Encoding: gzip, deflate
Upgrade: websocket
Sec-Fetch-Dest: websocket

...
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: <secret>
Sec-WebSocket-Extensions: permessage-deflate
date: Sat, 29 Jun 2024 16:20:51 GMT
server: uvicorn
```


## HTTP/2
HTTP/2 preserves HTTP/1.1 semantics (methods, paths, headers, status codes) but changes underlying transport.
It's incompatible with HTTP/1.1 on the wire.

Mostly it solves performance issues with HTTP/1.1:
1. On a single HTTP/2 connection you can have multiple interleaved logical requests and responses.
2. You can have duplex streams similar in functionality to websockets. This feature is used in grpc to provide stream-stream endpoints.
3. It's a binary protocol, headers can be compressed
   (since headers are read before figuring out encoding in HTTP/1.1, this means they can be only plaintext)

The most benefit from HTTP/2 comes on frontend (where you have a bunch of limits on a number of TCP connections to a single host/etc)
The problem with HTTP/2 is: since you have several logical threads of action on a single HTTP/2 connection and behind
a single HTTP/2 connection is a single TCP connection, this means that TCP head-of-the-line blocking will bite you
real good. That was the reason for HTTP/3 which doesn't use TCP and uses QUIC (essentially TCP-like in userland backed by UDP)

For backend the most compelling feature is duplex streams.