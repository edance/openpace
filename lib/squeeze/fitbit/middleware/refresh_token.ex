defmodule Squeeze.Fitbit.Middleware.RefreshToken do
  @moduledoc """
  Tesla middleware that handles OAuth2 token refresh for Fitbit API requests.

  When a request receives a 401 Unauthorized response, this middleware:
  1. Attempts to refresh the access token using the provided refresh token
  2. Updates the request headers with the new access token
  3. Retries the original request
  4. Calls an optional callback with the new token information

  ## Options

    * `:refresh_token` - The OAuth2 refresh token to use for token refresh
    * `:token_refreshed` - Optional callback function that receives the new OAuth2.Client
  """

  @behaviour Tesla.Middleware

  alias Squeeze.Fitbit.{Auth, Client}

  @doc """
  Handles the middleware processing of the request.
  """
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
    case Auth.get_token(grant_type: "refresh_token", refresh_token: refresh_token) do
      {:ok, %OAuth2.Client{} = client} ->
        %OAuth2.Client{token: %OAuth2.AccessToken{access_token: access_token}} = client

        token_refreshed(client, opts)

        env = Client.set_authorization_header(env, access_token)

        {:ok, env}

      _reply ->
        {:error, env}
    end
  end

  defp attempt_refresh_token(env, _refresh_token, _opts), do: {:error, env}

  # Invoke the optional `:token_refreshed` callback function if provided.
  defp token_refreshed(%OAuth2.Client{} = client, opts) do
    case Keyword.get(opts, :token_refreshed) do
      token_refreshed when is_function(token_refreshed, 1) ->
        token_refreshed.(client)

      _ ->
        nil
    end
  end
end
