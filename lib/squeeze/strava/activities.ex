defmodule Squeeze.Strava.Activities do
  @moduledoc """
  Wrapper around Strava.Activities
  """

  alias Squeeze.Accounts.User
  alias Squeeze.Strava.Client
  alias Strava.DetailedActivity

  import Strava.RequestBuilder

  def get_activity_by_id(%User{} = user, id) do
    user
    |> Client.new()
    |> Strava.Activities.get_activity_by_id(id)
  end

  def update_activity_by_id(user, activity_id, attrs) do
    user
    |> Client.new()
    |> Strava.Client.put("/activities/#{activity_id}", attrs)
    |> decode(%DetailedActivity{})
  end
end
