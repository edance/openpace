import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :squeeze, SqueezeWeb.Endpoint,
  url: [scheme: "http", host: "www.example.com", port: 80],
  http: [port: 4001],
  secret_key_base: "loAnOMQZRfauy3CxAygWKHtaLuZnU8yvA/xvnmEZ89n3I4K5Afs8tt3cpOdOPRgl",
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

config :squeeze, Squeeze.Mailer, adapter: Bamboo.TestAdapter

config :squeeze, :notification_provider, Squeeze.ExpoNotifications.MockNotificationProvider

config :squeeze, :strava_activities, Squeeze.Strava.MockActivities
config :squeeze, :strava_auth, Squeeze.Strava.MockAuth
config :squeeze, :strava_client, Squeeze.Strava.MockClient
config :squeeze, :strava_streams, Squeeze.Strava.MockStreams

config :squeeze, :payment_processor, Squeeze.MockPaymentProcessor

config :squeeze, Squeeze.OAuth2.Fitbit,
  client_id: "1",
  client_secret: "123456789",
  redirect_uri: "http://localhost:4000/auth/fitbit/callback",
  webhook_challenge: "FITBIT"

### Additional config

config :argon2_elixir, t_cost: 2, m_cost: 8

config :strava,
  client_id: "1",
  client_secret: "123456789",
  webhook_challenge: "STRAVA"

config :tesla, adapter: Tesla.Mock
