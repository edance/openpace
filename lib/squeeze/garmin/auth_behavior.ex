defmodule Squeeze.Garmin.AuthBehaviour do
  @moduledoc """
  Behaviour specification for Garmin authentication operations.
  """

  @doc """
  Gets the Garmin user information.
  """
  @callback get_user!(opts :: Keyword.t()) :: map()

  @doc """
  Generates the authorization URL with the given parameters.
  """
  @callback authorize_url!(params :: map()) :: String.t()

  @doc """
  Requests a temporary OAuth token from Garmin.
  """
  @callback request_token!(opts :: Keyword.t()) :: map()

  @doc """
  Exchanges the temporary token for an access token.
  """
  @callback get_token!(opts :: Keyword.t()) :: map()
end
