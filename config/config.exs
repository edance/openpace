# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :squeeze,
  ecto_repos: [Squeeze.Repo]

# Configures the endpoint
config :squeeze, SqueezeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WCLUlauy/dxYWO8mYasQnco/gwOZ/qhKGHmeoYB+vaSK1/LVOMQiIvwkU7F9MMFe",
  render_errors: [view: SqueezeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Squeeze.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :strava,
  client_id: System.get_env("STRAVA_CLIENT_ID"),
  client_secret: System.get_env("STRAVA_CLIENT_SECRET"),
  redirect_uri: "#{System.get_env("HOST_URL")}/auth/strava/callback"

config :squeeze, Squeeze.Guardian,
  issuer: "squeeze",
  secret_key: System.get_env("GUARDIAN_SECRET_KEY")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
