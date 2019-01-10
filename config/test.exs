use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :squeeze, SqueezeWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :squeeze, Squeeze.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "squeeze_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Test configuration for strava
config :strava,
  client_id: "1",
  client_secret: "123456789",
  redirect_uri: "http://localhost:4000/auth/strava/callback",
  webhook_challenge: "STRAVA"

config :squeeze, :strava_activities, Squeeze.Strava.MockActivities
config :squeeze, :strava_auth, Squeeze.Strava.MockAuth
config :squeeze, :strava_client, Squeeze.Strava.MockClient
config :squeeze, :strava_streams, Squeeze.Strava.MockStreams
