defmodule Squeeze.Strava.ActivityFormatter do
  @moduledoc """
  Translates a strava activity into an openpace activity
  """

  alias Strava.{DetailedActivity, SummaryActivity}

  def format(%SummaryActivity{} = strava_activity) do
    format_activity(strava_activity)
  end

  def format(%DetailedActivity{} = strava_activity) do
    format_activity(strava_activity)
  end

  defp format_activity(strava_activity) do
    %{
      name: strava_activity.name,
      type: strava_activity.type,
      activity_type: activity_type(strava_activity),
      distance: strava_activity.distance,
      duration: strava_activity.moving_time,
      start_at: strava_activity.start_date,
      start_at_local: strava_activity.start_date_local,
      elevation_gain: strava_activity.total_elevation_gain,
      external_id: "#{strava_activity.id}",
      planned_date: Timex.to_date(strava_activity.start_date_local),
      polyline: strava_activity.map.summary_polyline,
      workout_type: workout_type(strava_activity)
    }
  end

  defp workout_type(strava_activity) do
    case strava_activity.workout_type do
      1 -> :race
      2 -> :long_run
      3 -> :workout
      _ -> nil
    end
  end

  defp activity_type(strava_activity) do
    cond do
      String.contains?(strava_activity.type, "Run") -> :run
      String.contains?(strava_activity.type, "Ride") -> :bike
      String.contains?(strava_activity.type, "Swim") -> :swim
      true -> :other
    end
  end
end
