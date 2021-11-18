defmodule Squeeze.Application do
  @moduledoc false

  use Application

  alias SqueezeWeb.Endpoint

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      Squeeze.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Squeeze.PubSub},
      # Start the Endpoint (http/https)
      SqueezeWeb.Endpoint,
      # Start a worker by calling: Squeeze.Worker.start_link(arg)
      Squeeze.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Squeeze.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
