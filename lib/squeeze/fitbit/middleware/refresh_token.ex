defmodule Squeeze.Fitbit.Middleware.RefreshToken do
  @moduledoc """
  Attempt to refresh access token using provided refresh token on
  "401 Unauthorized" HTTP response codes.
  """

  @behaviour Tesla.Middleware

  def call(env, next, opts) do
    refresh_token = Keyword.get(opts, :refresh_token)

    with {:ok, %Tesla.Env{status: 401} = env} <- Tesla.run(env, next),
         {:ok, %Tesla.Env{} = env} <- attempt_refresh_token(env, refresh_token, opts) do
      # Retry request with refreshed access token
      Tesla.run(env, next)
    else
      {:error, %Tesla.Env{} = env} -> {:ok, env}
      reply -> reply
    end
  end

  # Attempt to refresh the access token using provided refresh token
  defp attempt_refresh_token(env, refresh_token, opts) when is_binary(refresh_token) do
    case Squeeze.Fitbit.Auth.get_token(grant_type: "refresh_token", refresh_token: refresh_token) do
      {:ok, %OAuth2.Client{} = client} ->
        %OAuth2.Client{token: %OAuth2.AccessToken{access_token: access_token}} = client

        token_refreshed(client, opts)

        env = Squeeze.Fitbit.Client.set_authorization_header(env, access_token)

        {:ok, env}

      _reply ->
        {:error, env}
    end
  end

  defp attempt_refresh_token(env, _refresh_token, _opts), do: {:error, env}

  # Invoke the optional `:token_refreshed` callback function if provided.
  defp token_refreshed(%OAuth2.Client{} = client, opts) do
    token_refreshed = Keyword.get(opts, :token_refreshed)

    if is_function(token_refreshed, 1) do
      apply(token_refreshed, [client])
    end
  end
end
