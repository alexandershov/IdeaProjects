## Systemd

Systemd is a process with pid 1, that controls everything.
It can control services.

See [service file](./my_app.service) for an example.

Do this on a fresh ec2 VM (after scp'ing [app.py](./app.py) and [my_app.service](./my_app.service) to it)
```shell
sudo apt-get update
sudo apt-get install -y python3-pip
sudo python3 -m pip install fastapi uvicorn
sudo cp my_app.service /etc/systemd/system/
```

Start service
```shell
sudo systemctl start my_app.service
```

Kill the service
```shell
curl -d {} localhost:8889/die
```

But the /ping is still working, because systemd has restarted service


```shell
journalctl -u my_app  # read logs of my_app
systemd[1]: my_app.service: Main process exited, code=exited, status=1/FAILURE
systemd[1]: my_app.service: Failed with result 'exit-code'.
systemd[1]: my_app.service: Consumed 1.119s CPU time.
systemd[1]: my_app.service: Scheduled restart job, restart counter is at 1
```

Enable service to load on boot
```shell
sudo systemctl enable my_app
```

systemctl also can do the usual: status/stop/start/restart

Systemd also supports cron-like stuff. See [pymash_monitoring](https://github.com/alexandershov/pymash/tree/master/deploy) for an example
