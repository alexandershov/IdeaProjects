## Caddy

Caddy is a web server similar to nginx.
It has support for automatic https via letsencrypt.
It's written in Go.

Install
```shell
brew install caddy
```

Start Caddy
```shell
caddy run
```

Look at config
```shell
curl localhost:2019/config/
```

It will return null, because by default Caddy starts with an empty configuration

We can configure caddy via curl. [config.json](./config.json) contains sample configuration.
```shell
curl -H 'Content-Type: application/json' -d @config.json localhost:2019/load 
```

Now http://localhost:2015 will respond with "Hello, world!".

Configuring Caddy with json looks like total shit. 
We can configure Caddy with [Caddyfile](./Caddyfile) which is a custom human-readable format
similar to nginx config.

Stop Caddy and run it again:
```shell
caddy run
```

Now we're serving from Caddyfile, that's much better than jsons.
http://localhost:2016


Caddy can reload config without downtime:
```shell
caddy reload
```

Convert Caddyfile to json
```shell
caddy adapt
```

Caddy supports automatic https.

Install network security services
```shell
brew install nss
```

Run caddy with https-enabled Caddyfile (it uses domain name for port 2016, and Caddy enables https in this case)
```shell
caddy run -c Caddyfile_https
```

Caddy will ask for a permission to add certificate.

After that site will be served via https: https://localhost:2016 

For localhost Caddy will issue self-signed certificate.
For different domains Caddy will get a certificate from let's encrypt.