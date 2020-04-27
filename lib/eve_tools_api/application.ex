defmodule EveToolsApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      EveToolsApi.Repo,
      # Start the Telemetry supervisor
      EveToolsApiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: EveToolsApi.PubSub},
      # Start the Endpoint (http/https)
      EveToolsApiWeb.Endpoint,
      # Start a worker by calling: EveToolsApi.Worker.start_link(arg)
      {ConCache, [name: :esi_cache, ttl_check_interval: false]}
      # {EveToolsApi.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EveToolsApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EveToolsApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
