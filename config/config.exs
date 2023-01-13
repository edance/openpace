# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :squeeze,
  ecto_repos: [Squeeze.Repo]

# Configures the endpoint
config :squeeze, SqueezeWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: SqueezeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Squeeze.PubSub,
  live_view: [signing_salt: "0tmEgY9y"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
# config :squeeze, Squeeze.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
# config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :squeeze, Squeeze.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: System.get_env("SENDGRID_API_KEY")

config :squeeze, :notification_provider, Squeeze.ExpoNotifications.DefaultNotificationProvider

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

config :strava,
  client_id: System.get_env("STRAVA_CLIENT_ID"),
  client_secret: System.get_env("STRAVA_CLIENT_SECRET"),
  webhook_challenge: System.get_env("STRAVA_WEBHOOK_TOKEN")

config :squeeze, Squeeze.Scheduler,
  jobs: [
    {"0 * * * *", {Squeeze.Notifications, :batch_notify_challenge_start, []}}, # Run every hour
    {"0 * * * *", {Squeeze.Notifications, :batch_notify_challenge_ending, []}}, # Run every hour
    {"0 * * * *", {Squeeze.Notifications, :batch_notify_challenge_ended, []}}, # Run every hour
  ]

config :algolia,
  application_id: System.get_env("ALGOLIA_APPLICATION_ID"),
  api_key: System.get_env("ALGOLIA_API_KEY")

config :tesla, adapter: Tesla.Adapter.Hackney

config :slack, api_token: System.get_env("SLACK_TOKEN")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
