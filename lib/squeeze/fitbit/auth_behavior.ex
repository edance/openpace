defmodule Squeeze.Fitbit.AuthBehaviour do
  @moduledoc """
  Behaviour module defining callbacks for Fitbit OAuth authentication.
  """

  @type client :: OAuth2.Client.t()
  @type token :: OAuth2.AccessToken.t()
  @type headers :: [{binary, binary}]
  @type credential :: %{
          access_token: binary,
          refresh_token: binary,
          provider: binary,
          uid: binary
        }
  @type scope :: String.t()
  @type code :: String.t()
  @type grant_type :: String.t()
  @type token_opts :: [
          code: code,
          grant_type: grant_type,
          refresh_token: binary
        ]
  @type auth_opts :: [
          scope: scope,
          expires_in: integer
        ]

  @doc """
  Generates the authorization URL for the OAuth2 flow.
  """
  @callback authorize_url!() :: String.t()
  @callback authorize_url!(auth_opts()) :: String.t()

  @doc """
  Gets an OAuth2 token, raising an error if the request fails.
  """
  @callback get_token!() :: client()
  @callback get_token!(token_opts()) :: client()
  @callback get_token!(token_opts(), headers()) :: client()

  @doc """
  Gets an OAuth2 token, returns {:ok, client} or {:error, reason}.
  """
  @callback get_token() :: {:ok, client()} | {:error, any()}
  @callback get_token(token_opts()) :: {:ok, client()} | {:error, any()}
  @callback get_token(token_opts(), headers()) :: {:ok, client()} | {:error, any()}

  @doc """
  Creates credential map from OAuth2 client response.
  """
  @callback get_credential!(client()) :: credential()

  @doc """
  Creates a new OAuth2 client with default configuration.
  """
  @callback new() :: client()
end
