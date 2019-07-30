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
      "Workout"
    ]
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
