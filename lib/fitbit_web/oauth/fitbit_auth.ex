defmodule FitbitAuth do
  use OAuth2.Strategy

  alias OAuth2.Strategy.AuthCode

  def client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: System.get_env("FITBIT_CLIENT_ID"),
      client_secret: System.get_env("FITBIT_CLIENT_SECRET"),
      redirect_uri: "https://powerful-reef-10480.herokuapp.com/auth/fitbit/callback",
      site: "https://api.fitbit.com",
      authorize_url: "https://www.fitbit.com/oauth2/authorize",
      token_url: "https://api.fitbit.com/oauth2/token",
    ])
  end

  def authorize_url!(params \\ []) do
    OAuth2.Client.authorize_url!(client(), params)
  end

  def get_token!(params \\ [], headers \\ []) do
    OAuth2.Client.get_token!(client(), params, headers)
  end

  # strategy callbacks

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def basic_auth_header do
    id = System.get_env("FITBIT_CLIENT_ID")
    secret = System.get_env("FITBIT_CLIENT_SECRET")
    "Basic " <> Base.encode64("#{id}:#{secret}")
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> put_header("Authorization", basic_auth_header())
    |> AuthCode.get_token(params, headers)
  end
end
