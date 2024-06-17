## Networks

### IP
IP is a simple protocol, it can send data between IP addresses.

### UDP
UDP is a simple extension of IP. Essentially it adds ports to IP

### tcpdump

tcpdump is a packet analyzer.


Set up "server"
```shell
nc -l 1234
```

Analyze tcp packets on port 1234 
```shell
sudo tcpdump -i any tcp port 1234
```

Send
```shell
echo test | nc localhost 1234
```

