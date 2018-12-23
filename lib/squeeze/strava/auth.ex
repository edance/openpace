defmodule Squeeze.Strava.AuthBehavior do
  @moduledoc """
  Auth behavior to allow us to use mocks for Strava
  """
  @callback authorize_url!([]) :: String.t
  @callback get_token!([]) :: map()
  @callback get_athlete!(map()) :: map()
end

defmodule Squeeze.Strava.Auth do
  @moduledoc """
  Wrapper module for the strava auth library
  """

  @behaviour Squeeze.Strava.AuthBehavior

  alias Strava.Auth

  def authorize_url!(params), do: Auth.authorize_url!(params)
  def get_token!(params), do: Auth.get_token!(params)
  def get_athlete!(client), do: Auth.get_athlete!(client)
end
