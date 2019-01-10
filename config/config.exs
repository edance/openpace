# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :squeeze,
  ecto_repos: [Squeeze.Repo]

# Configures the endpoint
config :squeeze, SqueezeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "dQoFqEeDanLKBUOlYj3JJN3GOKv3AK9id6Je17YxqP2wg+c1Bs8ckUPo9YDTPD1k",
  render_errors: [view: SqueezeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Squeeze.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :strava,
  client_id: System.get_env("STRAVA_CLIENT_ID"),
  client_secret: System.get_env("STRAVA_CLIENT_SECRET"),
  redirect_uri: "http://localhost:4000/auth/strava/callback",
  webhook_challenge: System.get_env("STRAVA_WEBHOOK_TOKEN")

config :squeeze, gtm_id: System.get_env("GTM_ID")
config :squeeze, mapbox_access_token: System.get_env("MAPBOX_ACCESS_TOKEN")

config :squeeze, :strava_activities, Strava.Activities
config :squeeze, :strava_auth, Strava.Auth
config :squeeze, :strava_client, Strava.Client
config :squeeze, :strava_streams, Strava.Streams

config :squeeze, Squeeze.Guardian,
  issuer: "squeeze",
  secret_key: "1kALJhfwksHIiVmnVwuZv327H+u1jnE7ZC/c3EAJcurvH5sAHbm+KA87R/eivO29"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
