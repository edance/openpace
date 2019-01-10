defmodule Strava.StreamsBehavior do
  @moduledoc """
  Streams behavior to allow us to use mocks for Strava.Streams
  """

  @callback get_activity_streams(
    Tesla.Env.client(),
    integer(),
    list(String.t()),
    boolean()
  ) :: {:ok, Strava.StreamSet.t()} | {:error, Tesla.Env.t()}
end
