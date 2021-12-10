defmodule Squeeze.Strava.Activities do
  @moduledoc """
  Wrapper around Strava.Activities
  """

  alias Squeeze.Accounts.User
  alias Squeeze.Strava.Client

  @strava_activities Application.compile_env(:squeeze, :strava_activities)

  def get_activity_by_id(%User{} = user, id) do
    user
    |> Client.new
    |> @strava_activities.get_activity_by_id(id)
  end
end
