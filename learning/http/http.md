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

## Compression
Compression in http can be done by specifying `Accept-Encoding: gzip` (or another compression method)
If server supports this encoding it'll apply it to response and add `Content-Encoding: gzip` header to response.
```shell
GET /health HTTP/1.1
host: localhost
Accept-Encoding: gzip

HTTP/1.1 200 OK
date: Sat, 29 Jun 2024 16:44:30 GMT
server: uvicorn
content-length: 36
content-type: application/json
content-encoding: gzip
vary: Accept-Encoding

<binary gzipped response>
```

This requires setup on a server side (e.g. adding gzip middleware in fastapi)


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

## HTTPS & TLS

HTTPS is HTTP over TLS.
TLS is a Transport Level Security. It allows you to have encrypted communication, so that man-in-the-middle can't 
eavesdrop on it. Technically TLS is different from SSL (SSL is an older thing), but these terms are often used
interchangeably and are essentially different versions of the same protocol.

TLS itself rides over TCP. TLS records are max 16kb. If you send too small TLS records then you pay framing/computational overhead.
If you send too large TLS records, then you can be victim of TCP head-of-the line blocking.

TLS is binary protocol, you can't deduce much from tcpdump (and everything is encrypted after cryptography details negotiation anyway):
```shell
sudo tcpdump -A -i any tcp port 443 and host google.com
```

You'll see the hostname in plaintext though, so with HTTPS you'll hide everything from the mitm except for your and 
server address (and/or hostname).

### Cryptography

Symmetric cryptography uses a single key for encrypting and decrypting.
Asymmetric cryptography uses one key for encrypting (public key) and another key (private key) for decrypting.
Public key is, ahem, public and can be shared with anybody.
Private key is, ahem, private and must be kept secret.

Public key and private key are generated together as a pair.

Two important properties of asymmetric cryptography:
1. Message encrypted with the public key can be only decrypted with the corresponding private key
2. Using private key you can sign a message. Using public key other side can validate  
   that message was indeed signed by the corresponding private key.


### Handshake
In the naive implementation TLS adds 2 RTTs, one is to exchange details of a crypto algorithms, another to generate symmetric key.
Validating server identity is done with [Certificates](#Certificates) which are based on asymmetric cryptography.
Once symmetric key is generated, it's used to encrypt/decrypt messages.

Symmetric key can be generated with RSA method:
1. Client generates secret key, encrypts it with the server public key
2. Server decrypts it with its private key

The disadvantage of this method is once private key is compromised, it can be used to decrypt all past exchanges.
because encrypted symmetric key was put on the wire.

Better method is e.g. Diffie-Hellman. It allows client and server to share symmetric key without putting it on the wire.
It's based on modulo/power operations on Very Large numbers and function f(x, y, z) = (x ** y) % z.
1. Client and server agree on numbers g, p.
2. Client and server generate its own secret numbers C and S.
3. Client puts on the wire f(g, C, p) = C1, server puts on the wire f(g, S, p) = S1
4. Client calculates f(S1, C, p), server calculates f(C1, S, p)
5. Math checks out f(S1, C, p) = f(C1, S, p). Now client and server have a common key, that can be used for symmetric
   cryptography.

Mitm will know g, p, C1, S1, but it's incredibly computationally expensive (== impossible in any reasonable time using current
technology) to figure out C and S and corresponding symmetric key.

With Diffie-Hellman even if attacker knows server private key this won't help him to decrypt past exchanges. 

Since TLS adds RTTs, keep-alive becomes even more important in HTTPS.
TLS adds some computational overhead (because of crypto), but not much (~1% overhead), and it can be done on commodity hardware.

### Handshake optimizations
We can reduce number of RTTs in TLS handshake:
1. TLS false start: client can start sending application data (HTTP request in our case) immediately after sending its
   part of Diffie-Hellman exchange without waiting for server part.
2. Server can return Session-Id, and client can pass it in the next connections. It requires storing some state
   on a server (to find it by Session-Id), so another option is: 
3. Server can return Session Ticket, which is encrypted session info. So client stores session details and can pass it
   in the next connection. Here server should be careful on how to encrypt session info, how to rotate keys used for 
   its encryption etc. 

### Certificates
With TLS you can check that the server e.g. google.com is indeed google.com.

During the TLS handshake client receives server certificate. Certificate contains public key 
(private key remains, ahem, private to the server), host name and signing information.
You can't trust any certificate, because you can't be sure that mitm is not faking google.com.
But you can have a limited number of authorities that you trust. These authorities are bundled with OS/browser/added manually.
You can look at root CAs in /etc/ssl 

The authorities are called Certificate Authorities (CAs).
E.g. google.com can ask some CA to sign google.com certificate. If you trust this CA then it's cool.
If not, then this CA certificate can be signed by another CA. So you'll (hopefully) get to some CA you trust.
This root CA can self-sign its own certificate.

Signing is done with private key, signing check is done with
the public key.

This is called chain of trust. You can look at certificate chain, by visiting any https site and clicking on green
padlock. Or with `openssl`:
```shell
openssl s_client -state -connect google.com:443
```

There's analog of HTTP/1.1 `Host` header in TLS, it's called SNI (Server Name Indication), so you can serve different hosts
from a single ip address.

Certificates can be revoked (for any number of reason: e.g. if private key is expired). Client can check that with:
1. Fetching some list of expired certificates (cons: lists can be huge)
2. Asking CA if certificate is expired (cons: adds latency, CA request can timeout)
3. Rely on Staple-Record which is sent by the server and contains cryptographically signed (by CA) info about revocation.
   Server can fetch staple-record data in background.