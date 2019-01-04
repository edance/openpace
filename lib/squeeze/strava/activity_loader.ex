defmodule Squeeze.Strava.ActivityLoader do
  @moduledoc """
  Loads data from strava and updates the activity
  """

  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard
  alias Squeeze.Dashboard.Activity
  alias Squeeze.Strava.Client
  alias Squeeze.TimeHelper

  @strava_activities Application.get_env(:squeeze, :strava_activities)

  def update_or_create_activity(%User{} = user, %{type: type} = strava_activity) do
    if String.contains?(type, "Run") do
      case get_closest_activity(user, strava_activity) do
        nil -> Dashboard.create_activity(user, map_strava_activity(strava_activity))
        activity ->
          activity
          |> Dashboard.update_activity(map_strava_activity(activity, strava_activity))
      end
    else
      {:ok, nil}
    end
  end
  def update_or_create_activity(%User{} = user, strava_activity_id) do
    {:ok, strava_activity} = fetch_strava_activity(user, strava_activity_id)
    update_or_create_activity(user, strava_activity)
  end

  def get_closest_activity(%User{} = user, strava_activity) do
    date = TimeHelper.to_date(user, strava_activity.start_date)
    activities = Dashboard.get_pending_activities_by_date(user, date)
    case length(activities) do
      x when x <= 1 -> List.first(activities)
      _ ->
        activities
        |> Enum.sort(fn(a, b) -> diff(a, strava_activity) < diff(b, strava_activity) end)
        |> List.first()
    end
  end

  defp fetch_strava_activity(%User{} = user, activity_id) do
    user
    |> Client.new
    |> @strava_activities.get_activity_by_id(activity_id)
  end

  def diff(%Activity{planned_distance: planned_distance}, %{distance: distance})
  when is_number(planned_distance) and planned_distance > 0 do
    abs(planned_distance - distance) / planned_distance
  end
  def diff(_, _), do: 1

  defp percent_complete(%Activity{planned_distance: planned_distance}, %{distance: distance})
  when is_number(planned_distance) and planned_distance > 0 do
    distance / planned_distance
  end
  defp percent_complete(_, _), do: 1

  defp activity_status(percentage) when percentage > 0.95, do: :complete
  defp activity_status(_), do: :partial

  defp map_strava_activity(activity, strava_activity)  do
    attrs = map_strava_activity(strava_activity)
    percent_complete = percent_complete(activity, strava_activity)
    %{attrs | name: activity.name, status: activity_status(percent_complete)}
  end

  defp map_strava_activity(strava_activity) do
    %{
      name: strava_activity.name,
      distance: strava_activity.distance,
      duration: strava_activity.moving_time,
      start_at: strava_activity.start_date,
      external_id: strava_activity.id,
      polyline: strava_activity.map.summary_polyline,
      status: :complete
    }
  end
end
