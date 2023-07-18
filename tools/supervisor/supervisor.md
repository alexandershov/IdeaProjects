## Supervisor

Supervisor is a process control system.

You describe the programs that supervisor control in a configuration file
and supervisor does the job.

Supervisor is written in Python.

It can start/stop/automatically restart dying processes etc.

Build docker image from [Dockerfile](./Dockerfile)

```shell
docker build -t supervisord_tutorial .
```

Start docker container with supervisor

```shell
docker run -p 8889:8889 -p 9001:9001 -it supervisord_tutorial
```

Ping

```shell
curl localhost:8889/ping
```

Kill the app

```shell
curl -d {} localhost:8889/die
```

Ping again
```shell
curl localhost:8889/ping
```

It works because supervisord has restarted an app

```text
2023-07-18 09:40:06,067 WARN exited: app (exit status 1; not expected)
2023-07-18 09:40:07,075 INFO spawned: 'app' with pid 8
2023-07-18 09:40:08,455 INFO success: app entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
```

supervisorctl is a cli tool for controlling supervisor.
It's pretty standard (supervisorctl status|stop|start|restart)
You need to add some sections in [supervisord.conf](./supervisord.conf) for it work.

Supervisor has a web interface. 
Web interface location is determined by `[inet_http_server]` config
You can restart/stop/app via web interface.