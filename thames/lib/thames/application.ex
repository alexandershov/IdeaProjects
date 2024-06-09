defmodule Thames.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ThamesWeb.Telemetry,
      Thames.Repo,
      {DNSCluster, query: Application.get_env(:thames, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Thames.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Thames.Finch},
      # Start a worker by calling: Thames.Worker.start_link(arg)
      # {Thames.Worker, arg},
      # Start to serve requests, typically the last entry
      ThamesWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Thames.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ThamesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
