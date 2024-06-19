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

Analyze tcp packets on loopback interface on port 8889 (you can list interfaces with `ifconfig`) 
```shell
sudo tcpdump -i lo0 tcp port 8889
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

Here's tcpdump of three-way handshake (S means SYN, `.` means ACK).
tcpdump results checks out with the theory
```text
02:57:20.040502 IP localhost.60472 > localhost.ddi-tcp-2: Flags [S], seq 3640016405, win 65535, options [mss 16344,nop,wscale 6,nop,nop,TS val 1826727395 ecr 0,sackOK,eol], length 0
02:57:20.040634 IP localhost.ddi-tcp-2 > localhost.60472: Flags [S.], seq 2752747578, ack 3640016406, win 65535, options [mss 16344,nop,wscale 6,nop,nop,TS val 1252349557 ecr 1826727395,sackOK,eol], length 0
02:57:20.040659 IP localhost.60472 > localhost.ddi-tcp-2: Flags [.], ack 1, win 6379, options [nop,nop,TS val 1826727395 ecr 1252349557], length 0
```