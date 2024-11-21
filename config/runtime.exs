import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/squeeze start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :squeeze, SqueezeWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6"), do: [:inet6], else: []

  config :squeeze, Squeeze.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "www.openpace.co"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :squeeze, SqueezeWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  config :squeeze, Squeeze.Guardian,
    issuer: "squeeze",
    secret_key: System.get_env("GUARDIAN_SECRET_KEY")

  config :squeeze, gtm_id: System.get_env("GTM_ID")

  config :squeeze, mapbox_access_token: System.get_env("MAPBOX_ACCESS_TOKEN")

  config :new_relic_agent,
    app_name: "OpenPace Production",
    license_key: System.get_env("NEW_RELIC_KEY"),
    logs_in_context: :direct

  config :squeeze, Squeeze.OAuth2.Google,
    client_id: System.get_env("GOOGLE_CLIENT_ID"),
    client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
    redirect_uri: "https://www.openpace.co/auth/google/callback"

  config :strava,
    client_id: System.get_env("STRAVA_CLIENT_ID"),
    client_secret: System.get_env("STRAVA_CLIENT_SECRET"),
    webhook_challenge: System.get_env("STRAVA_WEBHOOK_TOKEN")

  config :squeeze, Squeeze.Mailer,
    adapter: Bamboo.SendGridAdapter,
    api_key: System.get_env("SENDGRID_API_KEY")

  config :slack, api_token: System.get_env("SLACK_TOKEN")

  config :stripity_stripe,
    api_key: System.get_env("STRIPE_SECRET_KEY"),
    publishable_key: System.get_env("STRIPE_PUBLISHABLE_KEY"),
    webhook_secret: System.get_env("STRIPE_WEBHOOK_SECRET")

  config :squeeze, Squeeze.OAuth2.Fitbit,
    client_id: System.get_env("FITBIT_CLIENT_ID"),
    client_secret: System.get_env("FITBIT_CLIENT_SECRET"),
    redirect_uri: "https://www.openpace.co/integration/fitbit/callback",
    webhook_challenge: System.get_env("FITBIT_WEBHOOK_TOKEN")

  config :squeeze, Squeeze.Garmin,
    consumer_key: System.get_env("GARMIN_CONSUMER_KEY"),
    consumer_secret: System.get_env("GARMIN_CONSUMER_SECRET"),
    redirect_uri: "https://www.openpace.co/integration/garmin/callback"
end
