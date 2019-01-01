defmodule Strava.ClientBehavior do
  @moduledoc """
  Client behavior to allow us to use mocks for Strava.Client
  """
  @callback new(String.t, []) :: Tesla.Client
end
