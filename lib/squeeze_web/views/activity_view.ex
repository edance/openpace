defmodule SqueezeWeb.ActivityView do
  use SqueezeWeb, :view

  alias Squeeze.{Distances, Velocity}

  def title(_page, _assigns) do
    "Activities"
  end

  def activity_types do
    [
      "Run",
      "Bike",
      "Swim",
      "Cross Training",
      "Walk",
      "Strength Training",
      "Workout",
      "Yoga"
    ]
  end

  def name(%{activity: activity}) do
    activity.name || activity.type
  end

  def duration(%{activity: activity}) do
    cond do
      activity.duration && activity.duration > 0 ->
        format_duration(activity.duration)
      activity.planned_duration && activity.planned_duration > 0 ->
        format_duration(activity.planned_duration)
      true ->
        "N/A"
    end
  end

  def distance(%{activity: activity, current_user: user}) do
    cond do
      activity.distance_amount && activity.distance_unit ->
        "#{activity.distance_amount} #{activity.distance_unit}"
      activity.distance && activity.distance > 0 ->
        format_distance(activity.distance, user.user_prefs)
      activity.planned_distance_amount && activity.planned_distance_unit ->
        "#{activity.planned_distance_amount} #{activity.planned_distance_unit}"
      true ->
        "N/A"
    end
  end

  def elevation(%{activity: %{elevation_gain: nil}}), do: "N/A"
  def elevation(%{activity: activity, current_user: user}) do
    imperial = user.user_prefs.imperial
    value = Distances.to_feet(activity.elevation_gain, imperial: imperial)
    if imperial do
      "#{value} ft"
    else
      "#{value} m"
    end
  end

  def date(%{activity: %{start_at: nil, planned_date: date}}) do
    Timex.format!(date, "%b %-d, %Y ", :strftime)
  end
  def date(%{activity: activity, current_user: user}) do
    timezone = user.user_prefs.timezone
    activity.start_at
    |> Timex.to_datetime(timezone)
    |> Timex.format!("%b %-d, %Y %-I:%M %p ", :strftime)
  end

  def trackpoints?(%{trackpoints: trackpoints}) do
    length(trackpoints) > 0
  end

  def distance?(%{trackpoints: trackpoints}) do
    trackpoints
    |> Enum.take(5)
    |> Enum.map(&(&1.distance))
    |> Enum.any?(&(!is_nil(&1)))
  end

  def coordinates?(%{trackpoints: trackpoints}) do
    trackpoints
    |> Enum.take(5)
    |> Enum.map(&(&1.coordinates))
    |> Enum.any?(&(!is_nil(&1)))
  end

  def trackpoint_json(%{trackpoints: trackpoints, current_user: user}) do
    imperial = user.user_prefs.imperial
    trackpoints
    |> Enum.map(&(trackpoint(&1, imperial)))
    |> Jason.encode!()
  end

  defp trackpoint(t, imperial) do
    %{
      altitude: Distances.to_feet(t.altitude, imperial: imperial),
      cadence: t.cadence * 2,
      distance: Distances.to_float(t.distance, imperial: imperial),
      heartrate: t.heartrate,
      time: t.time,
      velocity: Velocity.to_float(t.velocity, imperial: imperial)
    }
  end
end
