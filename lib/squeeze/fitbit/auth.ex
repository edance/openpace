defmodule Squeeze.Fitbit.Auth do
  @moduledoc false

  use OAuth2.Strategy

  @defaults [
    strategy: __MODULE__,
    site: "https://api.fitbit.com",
    authorize_url: "https://www.fitbit.com/oauth2/authorize",
    token_url: "https://api.fitbit.com/oauth2/token"
  ]

  def new do
    config = Application.get_env(:squeeze, Squeeze.OAuth2.Fitbit)

    @defaults
    |> Keyword.merge(config)
    |> OAuth2.Client.new()
  end

  def authorize_url!(params \\ []) do
    OAuth2.Client.authorize_url!(new(), params)
  end

  def get_token(params \\ [], headers \\ []) do
    OAuth2.Client.get_token(new(), params, headers)
  end

  def get_token!(params \\ [], headers \\ []) do
    OAuth2.Client.get_token!(new(), params, headers)
  end

  def authorize_url(client, params) do
    client
    |> put_param(:response_type, "code")
    |> put_param(:client_id, client.client_id)
    |> put_param(:redirect_uri, client.redirect_uri)
    |> merge_params(params)
  end

  def get_token(client, params, headers) do
    {code, params} = Keyword.pop(params, :code, client.params["code"])
    {grant_type, params} = Keyword.pop(params, :grant_type)

    client
    |> put_param(:code, code)
    |> put_param(:grant_type, grant_type)
    |> put_param(:redirect_uri, client.redirect_uri)
    |> merge_params(params)
    |> put_header("Authorization", "Basic " <> Base.encode64(client.client_id <> ":" <> client.client_secret))
    |> put_header("Accept", "application/json")
    |> put_headers(headers)
  end

  def get_credential!(%{token: token}) do
    token
    |> Map.take([:access_token, :refresh_token])
    |> Map.merge(%{provider: "fitbit", uid: token.other_params["user_id"]})
  end
end
