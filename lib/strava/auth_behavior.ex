defmodule Strava.AuthBehavior do
  @moduledoc """
  Auth behavior to allow us to use mocks for Strava
  """
  @callback authorize_url!([]) :: String.t
  @callback get_token!([]) :: map()
  @callback get_athlete!(map()) :: map()
end
