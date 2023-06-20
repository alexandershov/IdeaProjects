## Traefik

Traefik is a cloud-friendly reverse proxy written in Go.
It can automatically discover new microservices and new microservices instances.

Start reverse-proxy service via docker-compose
```shell
docker-compose up -d reverse-proxy
```

Start `whoami` service, traefik listens to docker events
and adds new container routing rules via `labels` directive in docker-compose.yml
```shell
docker-compose up -d whoami
```

Traefik proxies this request to `whoami` container based on Host:
```shell
curl -H Host:whoami.docker.localhost http://127.0.0.1
```

... or based on path prefix:

```shell
curl http://127.0.0.1/my-api
```

Traefik web-interface is available on http://localhost:8080