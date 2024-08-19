## Containers

### Setup

Install:
```shell
curl -fsSL https://get.docker.com -o docker.sh
sudo sh ./docker.sh
```

Start service and set permission for socket:
```shell
sudo systemctl start docker
chmod o+w /var/run/docker.sock
```

Start container:
```shell
docker run -it ubuntu:24.04
```

