defmodule Squeeze.Strava.ActivityLoader do
  @moduledoc """
  Loads data from strava and updates the activity
  """

  alias Squeeze.Accounts.{Credential}
  alias Squeeze.ActivityMatcher
  alias Squeeze.Dashboard
  alias Squeeze.Strava.Client

  @strava_activities Application.get_env(:squeeze, :strava_activities)

  def update_or_create_activity(%Credential{} = credential, strava_activity_id)
  when is_binary(strava_activity_id) or is_integer(strava_activity_id) do
    {:ok, strava_activity} = fetch_strava_activity(credential, strava_activity_id)
    update_or_create_activity(credential, strava_activity)
  end

  def update_or_create_activity(%Credential{} = credential, strava_activity) do
    user = credential.user
    activity = map_strava_activity(strava_activity)
    case ActivityMatcher.get_closest_activity(user, activity) do
      nil -> Dashboard.create_activity(user, activity)
      existing_activity ->
        activity = %{activity | name: existing_activity.name}
        Dashboard.update_activity(existing_activity, activity)
    end
  end

  defp fetch_strava_activity(%Credential{} = credential, activity_id) do
    credential
    |> Client.new
    |> @strava_activities.get_activity_by_id(activity_id)
  end

  defp map_strava_activity(strava_activity) do
    %{
      name: strava_activity.name,
      type: strava_activity.type,
      distance: strava_activity.distance,
      duration: strava_activity.moving_time,
      start_at: strava_activity.start_date,
      external_id: "#{strava_activity.id}",
      polyline: strava_activity.map.summary_polyline
    }
  end
end
