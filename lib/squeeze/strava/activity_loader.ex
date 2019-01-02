defmodule Squeeze.Strava.ActivityLoader do
  @moduledoc """
  Loads data from strava and updates the activity
  """

  alias Squeeze.Accounts
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard
  alias Squeeze.TimeHelper

  @strava_activities Application.get_env(:squeeze, :strava_activities)
  @strava_client Application.get_env(:squeeze, :strava_client)

  def update_or_create_activity(%User{} = user, strava_activity_id) do
    {:ok, strava_activity} = fetch_strava_activity(user, strava_activity_id)
    case get_closest_activity(user, strava_activity) do
      nil -> Dashboard.create_activity(user, map_strava_activity(strava_activity))
      x -> Dashboard.update_activity(x, map_strava_activity(strava_activity))
    end
  end

  def get_closest_activity(%User{} = user, strava_activity) do
    date = TimeHelper.to_date(user, strava_activity.start_date)
    activities = Dashboard.get_incomplete_activities_by_date(user, date)
    case length(activities) do
      1 -> List.first(activities)
      _ -> List.first(activities) # match on duration or distance, check within threshold of 10%?
    end
  end

  defp fetch_strava_activity(%User{} = user, activity_id) do
    user
    |> strava_client()
    |> @strava_activities.get_activity_by_id(activity_id)
  end

  defp strava_client(%User{} = user) do
    credential = user.credential
    @strava_client.new(credential.access_token,
      refresh_token: credential.refresh_token,
      token_refreshed: &Accounts.update_credential(credential, Map.from_struct(&1.token))
    )
  end

  defp map_strava_activity(x) do
    %{
      name: x.name,
      distance: x.distance,
      duration: x.moving_time,
      start_at: x.start_date,
      external_id: x.id,
      polyline: x.map.summary_polyline,
      complete: true
    }
  end
end
