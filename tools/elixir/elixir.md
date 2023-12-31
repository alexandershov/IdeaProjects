## Elixir

Elixir is a functional language inspired by ruby that runs on BEAM.

Install elixir
```shell
brew install elixir
```

See [tutorial](./tutorial.exs) for more details.

Run tutorial:
```shell
elixir tutorial.exs
```

Install Phoenix - Elixir web framework.
mix is a build tool for Elixir
```shell
mix archive.install hex phx_new
```

Create new Phoenix project using liveview
```shell
mix phx.new app --live
```

Start dev server (you need to create postgres database `app_dev` for that)
```shell
cd app 
mix phx.server
```

App is running on http://localhost:4000

Liveview sends updates to client when changes happen on the server.
See an [example](./app/lib/app_web/live/light_live.ex) of liveview in action.

It's pretty awesome: you can mark html elements with the e.g. phx-click and
Phoenix will send events to your handle_event/3 function.

After handling event Phoenix will figure out what needs to rerendered and will send the
update to the browser. So you're getting interactive apps without writing js.

Liveview is implemented via websocket connection between browser and Elixir process. 