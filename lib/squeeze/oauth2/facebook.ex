defmodule Squeeze.OAuth2.Facebook do
  @moduledoc """
  An OAuth2 strategy for Facebook.
  """

  use OAuth2.Strategy

  alias OAuth2.Client
  alias OAuth2.Strategy.AuthCode

  @defaults [
    strategy: __MODULE__,
    site: "https://graph.facebook.com",
    authorize_url: "https://www.facebook.com/dialog/oauth",
    token_url: "/v2.8/oauth/access_token",
    token_method: :get
  ]

  def client(opts \\ []) do
    config = Application.get_env(:squeeze, Squeeze.OAuth2.Facebook)

    opts =
      @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)

    Client.new(opts)
  end

  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> Client.authorize_url!(params)
  end

  def get_token!(params \\ [], opts \\ []) do
    opts
    |> client
    |> Client.get_token!(params)
  end

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("Accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end

  def get_user!(client) do
    %{body: user} =
      Client.get!(client, "/me?fields=email,id,first_name,last_name")
    uid = user["id"]
    %{
      avatar: "https://graph.facebook.com/#{uid}/picture?type=square",
      email: user["email"],
      first_name: user["first_name"],
      last_name: user["last_name"],
      credential: %{
        access_token: client.token.access_token,
        provider: "facebook",
        uid: uid
      }
    }
  end
end
