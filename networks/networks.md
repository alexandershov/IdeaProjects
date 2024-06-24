## Networks


### IP Addresses
IPv4 is a 32-bit address. E.g. 127.0.0.1.
You can describe ranges of IPv4 addresses with /XX notation.
E.g. 127.0.0.1/24 describes all IPv4 addresses with the first 24 bits equal to 127.0.0
So it's essentially glob 127.0.0.*.

IPv6 is a 128-bit address. E.g. 0001:0002:0003:0004:000a:000b:000c:000d 
(it consists of 8 parts, each is 16-bit, 8 * 16 == 128).
Bunch of zeroes in IPv6 address can be replaced by :: (you can use it only once),
E.g. localhost is `::1`, which is the same as `0000:0000:0000:0000:0000:0000:0000:0001`

IPv4 and IPv6 are actually two incompatible protocols, IPv6 packet is incompatible with IPv4 packet.
So to support both IPv4 and IPv6 you need to have two implementations of network stacks.

### IP
IP is a simple protocol, it can send data between IP addresses.
IP packet has TTL, when it travels between routers TTL is decreased by 1. 
This is done to avoid infinitely traveling packets.

### UDP
UDP is a simple extension of IP. Essentially it adds ports to IP.

### tcpdump

tcpdump is a packet analyzer.


Set up server
```shell
python tcp_server.py --port 8889
```

Analyze tcp packets on loopback interface on port 8889 (you can list interfaces with `ifconfig`) 
```shell
sudo tcpdump -i lo0 tcp port 8889
```

Send
```shell
python tcp_client.py test --port 8889
```

tcpdump output:
```shell
10:52:39.146542 IP localhost.61274 > localhost.ddi-tcp-2: Flags [S], seq 3848198620, win 65535, options [mss 16344,nop,wscale 6,nop,nop,TS val 1456208078 ecr 0,sackOK,eol], length 0
10:52:39.146701 IP localhost.ddi-tcp-2 > localhost.61274: Flags [S.], seq 3915623198, ack 3848198621, win 65535, options [mss 16344,nop,wscale 6,nop,nop,TS val 465120611 ecr 1456208078,sackOK,eol], length 0
10:52:39.146729 IP localhost.61274 > localhost.ddi-tcp-2: Flags [.], ack 1, win 6379, options [nop,nop,TS val 1456208078 ecr 465120611], length 0
10:52:39.146740 IP localhost.ddi-tcp-2 > localhost.61274: Flags [.], ack 1, win 6379, options [nop,nop,TS val 465120611 ecr 1456208078], length 0
10:52:39.146869 IP localhost.61274 > localhost.ddi-tcp-2: Flags [P.], seq 1:5, ack 1, win 6379, options [nop,nop,TS val 1456208078 ecr 465120611], length 4
10:52:39.146887 IP localhost.ddi-tcp-2 > localhost.61274: Flags [.], ack 5, win 6379, options [nop,nop,TS val 465120611 ecr 1456208078], length 0
10:52:39.146906 IP localhost.61274 > localhost.ddi-tcp-2: Flags [F.], seq 5, ack 1, win 6379, options [nop,nop,TS val 1456208078 ecr 465120611], length 0
10:52:39.146928 IP localhost.ddi-tcp-2 > localhost.61274: Flags [.], ack 6, win 6379, options [nop,nop,TS val 465120611 ecr 1456208078], length 0
10:52:39.146981 IP localhost.ddi-tcp-2 > localhost.61274: Flags [P.], seq 1:5, ack 6, win 6379, options [nop,nop,TS val 465120611 ecr 1456208078], length 4
10:52:39.147012 IP localhost.61274 > localhost.ddi-tcp-2: Flags [R], seq 3848198626, win 0, length 0
```

`.` means ACK
`P` means PUSH (instruction to a receiving side to skip buffering and send it directly to app)
`S` means SYN
`F` means FIN

### TCP 

#### Opening connection
Famous (and somewhat confusingly named) three-way handshake is this:

Client generates its sequence number C. Send SYN packet to server with this number.
Server generates its own sequence number S. It responds with SYN with S and ACK for C + 1. 
It's a single packet SYN+ACK.
Client sends ACK for S + 1.
Handshake is complete and connection is ready to use.

ACK X means that sender received bytes `[0; X-1]` and expects byte #X.

Here's tcpdump of three-way handshake (S means SYN, `.` means ACK).
tcpdump results checks out with the theory
```text
02:57:20.040502 IP localhost.60472 > localhost.ddi-tcp-2: Flags [S], seq 3640016405, win 65535, options [mss 16344,nop,wscale 6,nop,nop,TS val 1826727395 ecr 0,sackOK,eol], length 0
02:57:20.040634 IP localhost.ddi-tcp-2 > localhost.60472: Flags [S.], seq 2752747578, ack 3640016406, win 65535, options [mss 16344,nop,wscale 6,nop,nop,TS val 1252349557 ecr 1826727395,sackOK,eol], length 0
02:57:20.040659 IP localhost.60472 > localhost.ddi-tcp-2: Flags [.], ack 1, win 6379, options [nop,nop,TS val 1826727395 ecr 1252349557], length 0
```

#### Closing connection
In theory connection is closed with four-way handshake.
Client sends FIN packet to server.
Server sends ACK for FIN.
Server sends FIN packet to client.
Client sends ACK for FIN.

In practice, it's possible to do it in a three-way handshake: FIN -> FIN-ACK -> ACK


#### Flow control & slow start
Receiver can tell sender to hold its horses with "receive window size" (rwnd).
Which is essentially: You can have at most `rwnd` of unacked data. 

The sender starts with a small congestion window (cwnd), which is essentially maximum number of unacked packets.
and gradually increases it as it receives ACKs from the
receiver. For each ACKed packet cwnd increases by 1. 
So we'll have exponential growth of cwnd (if every packet is ACKed, 
then for each X packets you'll increase cwnd by X and it'll be equal to 2X, then 4X, etc):
Obviously network has limited bandwidth, exponential growth is not sustainable, so eventually you'll
packet loss. Packet loss is used as feedback mechanism in TCP.
If you got packet loss, then another algorithm kicks-in, which on one hand doesn't want to be pessimistic and grow speed,
and on another hand it doesn't want to be to optimistic and overwhelm the network.

Since we have three-way handshake and slow start this means that:
* You pay a round-trip time for each new connection
* Speed at the beginning of your connection is not good.

That's why reusing TCP connections (keep-alive, http2) is important: 
since you pay the price of handshake and slow start only once for long standing connections.

Here's an example of slow start in action (notice that it takes some time to get to maximum speed):

![TCP Slow Start](tcp_slow_start.png)

Source code is [here](tcp_download.py)

#### Head-of-line blocking
Since TCP guarantees ordered delivery this means when packets A, B, C are sent and
packet A is lost, then application will need to wait until A gets delivered and will not see B and C
before that. That's head-of-line blocking. 


#### Fast retransmit
Let's say sender sends packets A, B, C, D, E.

Receiver gets A, acks it ACK(A + len(A))
Let's say B is lost.
C is received, but since it's out of order, we still send ACK(A + len(A))
D is received, it's also out of order, we send the same ACK.
E is received, same.

Now we get 3 duplicate ACKs.
Fast retransmit is triggered after 3 duplicate ACKS. 
In our case it resends packet B without waiting for retransmit timeout.


#### Nagle's algorithm
Let's say we have 3 small pieces of data: A, B, C.
We write A to a socket. This sends TCP packet with A.
We write B to a socket. With Nagle's algorithm we don't send it immediately, we wait for ACK of A.
We write C to a socket. With Nagle's algorithm we don't send it immediately, we wait for ACK of A.

We're getting ACK of A. Since B & C are small we send a single packet containing B+C.

Nagle's algorithm plays badly with delayed ACKS, you can disable it with TCP_NODELAY.
See source code in [tcp_nagle.py](./tcp_nagle.py)
Run it as:
````shell
nc -l 1234
````

Run with Nagle algorithm:
```shell
NGL_HOST=localhost NGL_PORT=1234 NGL_TCP_NODELAY=0 python tcp_nagle.py
```

Run without Nagle algorithm:
```shell
NGL_HOST=localhost NGL_PORT=1234 NGL_TCP_NODELAY=1 python tcp_nagle.py
```

You can see results with tcpdump:
```shell
sudo tcpdump -i lo0 tcp port 1234
```
We'll get only 2 PUSHes with Nagle. And 9 PUSHes without it.


### Sockets
Sockets are extra abstraction over network protocols. 
They have their own (separate from TCP) receive/send buffers.


### DNS
DNS is implemented on UDP on port 53

You can look at dns traffic:
```shell
sudo tcpdump -i any udp port 53
```

`dig` can make dns queries:

```shell
dig google.com
;; ANSWER SECTION:
google.com.		148	IN	A	142.250.179.142
```

`148` is TTL in seconds, `A` is an address record type, essentially mapping of name to IPv4 address.
AAAA is the same as A, just for IPv6.

tcpdump for that dig query is:
```shell
# ask for an address (A?) of google.com
20:47:01.041952 IP alexanders-mbp.home.63947 > home.domain: 60002+ [1au] A? google.com. (39)
# result
20:47:01.055565 IP home.domain > alexanders-mbp.home.63947: 60002 1/0/1 A 142.250.179.142 (55)
```

if we dig for non-existing domain e.g. `googlekjdfff.com`, then we'll get NXDomain, which means domain doesn't exist.
NXDomain answers are also cached.

```shell
20:49:43.732249 IP alexanders-mbp.home.64213 > home.domain: 28942+ [1au] A? googlekjdfff.com. (45)
20:49:43.754266 IP home.domain > alexanders-mbp.home.64213: 28942 NXDomain 0/1/1 (118)
```

When you want to resolve host.org to ip address then 
* you ask well-known root dns servers for that
* root servers essentially redirect you to .org servers
* .org servers redirect you to host.org servers
* and then you'll get an ip address

Each of these steps can be (and will be) cached.

CNAME is name alias, e.g. mask.icloud.com is an alias for mask.apple-dns.net
```shell
dig +all mask.icloud.com
;; ANSWER SECTION:
mask.icloud.com.	38267	IN	CNAME	mask.apple-dns.net.
mask.apple-dns.net.	116	IN	A	17.248.176.9
```

### Restrictions

Run process without network access (linux)

```shell
unshare -r -n ping 8.8.8.8
```

### Observability

Search for processes listening on a port 1234 (you may need a `sudo` to find processes of other users):
````shell
lsof -i :1234
````

Find tcp connections of a process <pid>
```shell
lsof -p <pid> | grep -i tcp
```

List all connections of a pid:
```shell
sudo netstat -tupn | grep <pid>
```

Look at tcp traffic at <port>
```shell
sudo tcpdump -i any tcp port <port>
```
