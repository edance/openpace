# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :squeeze,
  ecto_repos: [Squeeze.Repo]

config :phoenix, :json_library, Jason

# Configures the endpoint
config :squeeze, SqueezeWeb.Endpoint,
  url: [scheme: "http", host: "localhost", port: 4000],
  secret_key_base: "dQoFqEeDanLKBUOlYj3JJN3GOKv3AK9id6Je17YxqP2wg+c1Bs8ckUPo9YDTPD1k",
  render_errors: [view: SqueezeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Squeeze.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :squeeze, Squeeze.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: System.get_env("SENDGRID_API_KEY")

config :squeeze, gtm_id: System.get_env("GTM_ID")
config :squeeze, mapbox_access_token: System.get_env("MAPBOX_ACCESS_TOKEN")

config :squeeze, :strava_activities, Strava.Activities
config :squeeze, :strava_auth, Strava.Auth
config :squeeze, :strava_client, Strava.Client
config :squeeze, :strava_segments, Strava.Segments
config :squeeze, :strava_streams, Strava.Streams

config :squeeze, :payment_processor, Squeeze.StripePaymentProcessor

config :squeeze, Squeeze.Guardian,
  issuer: "squeeze",
  secret_key: "1kALJhfwksHIiVmnVwuZv327H+u1jnE7ZC/c3EAJcurvH5sAHbm+KA87R/eivO29"

config :stripity_stripe,
  api_key: System.get_env("STRIPE_SECRET_KEY"),
  publishable_key: System.get_env("STRIPE_PUBLISHABLE_KEY"),
  webhook_secret: System.get_env("STRIPE_WEBHOOK_SECRET")

config :squeeze, Squeeze.OAuth2.Google,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
  redirect_uri: "http://localhost:4000/auth/google/callback"

config :squeeze, Squeeze.OAuth2.Fitbit,
  client_id: System.get_env("FITBIT_CLIENT_ID"),
  client_secret: System.get_env("FITBIT_CLIENT_SECRET"),
  redirect_uri: "http://localhost:4000/integration/fitbit/callback",
  webhook_challenge: System.get_env("FITBIT_WEBHOOK_TOKEN")

config :strava,
  client_id: System.get_env("STRAVA_CLIENT_ID"),
  client_secret: System.get_env("STRAVA_CLIENT_SECRET"),
  redirect_uri: "http://localhost:4000/integration/strava/callback",
  webhook_challenge: System.get_env("STRAVA_WEBHOOK_TOKEN")

config :squeeze, Squeeze.Garmin,
  consumer_key: System.get_env("GARMIN_CONSUMER_KEY"),
  consumer_secret: System.get_env("GARMIN_CONSUMER_SECRET"),
  redirect_uri: "http://localhost:4000/integration/garmin/callback"

config :algolia,
  application_id: System.get_env("ALGOLIA_APPLICATION_ID"),
  api_key: System.get_env("ALGOLIA_API_KEY")

config :tesla, adapter: Tesla.Adapter.Hackney

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
