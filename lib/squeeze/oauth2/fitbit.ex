defmodule Squeeze.OAuth2.Fitbit do
  @moduledoc """
  An OAuth2 strategy for Fitbit.
  """

  use OAuth2.Strategy

  alias OAuth2.Client
  alias OAuth2.Strategy.AuthCode

  @defaults [
    strategy: __MODULE__,
    site: "https://api.fitbit.com",
    authorize_url: "https://www.fitbit.com/oauth2/authorize",
    token_url: "https://api.fitbit.com/oauth2/token"
  ]

  # Public API

  def client(opts \\ []) do
    config = Application.get_env(:squeeze, Squeeze.OAuth2.Fitbit)

    @defaults
    |> Keyword.merge(config)
    |> Keyword.merge(opts)
    |> Client.new()
  end

  def authorize_url!(params \\ []) do
    Client.authorize_url!(client(), params)
  end

  def get_token!(params \\ [], _headers \\ []) do
    Client.get_token!(client(), Keyword.merge(params, client_secret: client().client_secret))
  end

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> put_header("Authorization", "Basic " <> Base.encode64(client.client_id <> ":" <> client.client_secret))
    |> AuthCode.get_token(params, headers)
  end
end
