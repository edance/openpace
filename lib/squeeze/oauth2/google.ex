defmodule Squeeze.OAuth2.Google do
  @moduledoc """
  An OAuth2 strategy for Google.
  """

  use OAuth2.Strategy

  alias OAuth2.Client
  alias OAuth2.Strategy.AuthCode

  @defaults [
    strategy: __MODULE__,
    site: "https://accounts.google.com",
    authorize_url: "/o/oauth2/auth",
    token_url: "/o/oauth2/token"
  ]

  # Public API

  def client(opts \\ []) do
    config = Application.get_env(:squeeze, Squeeze.OAuth2.Google)

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
    |> AuthCode.get_token(params, headers)
  end
end
