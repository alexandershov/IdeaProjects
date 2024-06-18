## Networks

### IP
IP is a simple protocol, it can send data between IP addresses.

### UDP
UDP is a simple extension of IP. Essentially it adds ports to IP.

### tcpdump

tcpdump is a packet analyzer.


Set up server
```shell
python tcp_server.py --port 8889
```

Analyze tcp packets on port 1234 
```shell
sudo tcpdump -i any tcp port 8889
```

Send
```shell
python tcp_client.py test --port 8889
```

### TCP 

#### Open connection
Famous (and somewhat confusingly named) three-way handshake is this:

Client generates its sequence number C. Send SYN packet to server with this number.
Server generates its own sequence number S. It responds with SYN with S and ACK for C + 1. 
It's a single packet SYN+ACK.
Client sends ACK for S + 1.
Handshake is complete and connection is ready to use.

ACK X means that sender received bytes `[0; X-1]` and expects byte #X.