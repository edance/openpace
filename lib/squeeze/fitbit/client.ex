defmodule Squeeze.Fitbit.Client do
  @moduledoc """
  Handle Tesla connections for Fitbit.
  """

  use Tesla

  alias Squeeze.Fitbit.Middleware

  adapter(Tesla.Adapter.Hackney)

  plug(Tesla.Middleware.BaseUrl, "https://api.fitbit.com")
  plug Tesla.Middleware.JSON

  @spec new(String.t()) :: Tesla.Env.client()
  def new(access_token, opts \\ []) when is_binary(access_token) do
    Tesla.client([
      {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{access_token}"}]},
      {Middleware.RefreshToken, opts}
    ])
  end

  def get_daily_activity_summary(client, date) do
    url = "/1/user/-/activities/date/#{date}.json"
    client
    |> get(url)
  end

  @doc false
  def set_authorization_header(%Tesla.Env{} = env, access_token) do
    %Tesla.Env{env | headers: [{"Authorization", "Bearer #{access_token}"}]}
  end
end
