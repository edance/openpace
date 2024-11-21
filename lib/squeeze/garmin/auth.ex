defmodule Squeeze.Garmin.Auth do
  @moduledoc """
  Garmin authentication integration.
  """

  @behaviour Squeeze.Garmin.AuthBehaviour

  alias Squeeze.Garmin.Client

  def get_user!(opts) do
    url = "https://healthapi.garmin.com/wellness-api/rest/user/id"

    opts
    |> Client.new()
    |> Client.get!(url)
    |> Map.get(:body)
  end

  def authorize_url!(params) do
    callback = redirect_uri()
    query_params = URI.encode_query(params)
    "https://connect.garmin.com/oauthConfirm?#{query_params}&oauth_callback=#{callback}"
  end

  def request_token!(opts \\ []) do
    url = "https://connectapi.garmin.com/oauth-service/oauth/request_token"

    opts
    |> Client.new()
    |> Client.post!(url, [])
    |> Map.get(:body)
    |> URI.decode_query()
  end

  def get_token!(opts \\ []) do
    url = "https://connectapi.garmin.com/oauth-service/oauth/access_token"

    opts
    |> Client.new()
    |> Client.post!(url, [])
    |> Map.get(:body)
    |> URI.decode_query()
  end

  def redirect_uri do
    Application.get_env(:squeeze, Squeeze.Garmin)
    |> Keyword.get(:redirect_uri, "http://localhost:4000/auth/garmin/callback")
  end
end
