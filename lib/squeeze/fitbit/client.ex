defmodule Squeeze.Fitbit.Client do
  @moduledoc """
  Handle Tesla connections for Fitbit.
  """

  use Tesla

  alias Squeeze.Fitbit.Middleware

  adapter(Tesla.Adapter.Hackney)

  plug(Tesla.Middleware.BaseUrl, "https://api.fitbit.com")

  @spec new(String.t()) :: Tesla.Env.client()
  def new(access_token, opts \\ []) when is_binary(access_token) do
    Tesla.client([
      {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{access_token}"}]},
      {Middleware.RefreshToken, opts}
    ])
  end

  @doc false
  def set_authorization_header(%Tesla.Env{} = env, access_token) do
    %Tesla.Env{env | headers: [{"Authorization", "Bearer #{access_token}"}]}
  end

  # defp request_opts do
  #   [
  #     adapter: [
  #       connect_timeout: Strava.connect_timeout(),
  #       recv_timeout: Strava.recv_timeout()
  #     ]
  #   ]
  # end
end
