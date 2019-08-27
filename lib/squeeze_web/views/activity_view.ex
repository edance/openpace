defmodule SqueezeWeb.ActivityView do
  use SqueezeWeb, :view

  alias Squeeze.Distances

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

  def splits(assigns) do
    trackpoints = split_trackpoints(assigns)
    trackpoints
    |> Enum.with_index()
    |> Enum.map(fn({point, idx}) ->
      if idx == 0 do
        split(point, nil)
      else
        split(point, Enum.at(trackpoints, idx - 1))
      end
    end)
  end

  defp split(trackpoint, nil), do: split(trackpoint, %{time: 0})
  defp split(trackpoint, %{time: prev_time}) do
    trackpoint
    |> Map.take([:distance, :time])
    |> Map.put(:pace, trackpoint.time - prev_time)
  end

  defp split_trackpoints(%{current_user: user, trackpoints: trackpoints})
  when length(trackpoints) != 0 do
    imperial = user.user_prefs.imperial
    trackpoints
    |> Enum.group_by(&Distances.to_int(&1.distance, imperial: imperial))
    |> Enum.map(fn({_, v}) -> List.first(v) end)
    |> Enum.filter(&(&1.distance > 0)) # remove splits for t0
    |> Enum.concat([List.last(trackpoints)]) # add the end trackpoint
  end
  defp split_trackpoints(_), do: []
end
