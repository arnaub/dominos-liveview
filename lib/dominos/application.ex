defmodule Dominos.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Dominos.Repo,
      # Start the Telemetry supervisor
      DominosWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Dominos.PubSub},
      ## Start presence Supervisor
      DominosWeb.Presence,
      # Start the Endpoint (http/https)
      DominosWeb.Endpoint,
      # Start a worker by calling: Dominos.Worker.start_link(arg)
      # {Dominos.Worker, arg}
      {Registry, keys: :unique, name: Dominos.GameRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: Dominos.GameSupervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dominos.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DominosWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
