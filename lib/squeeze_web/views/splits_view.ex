defmodule SqueezeWeb.SplitsView do
  use SqueezeWeb, :view

  alias Squeeze.Distances

  def splits(%{trackpoints: trackpoints} = assigns) do
    trackpoints
    |> Enum.chunk_by(&(trunc(&1.distance / split_distance(assigns))))
    |> Enum.with_index()
    |> Enum.map(&calc_split/1)
  end

  def split_distance(%{current_user: user}) do
    imperial = user.user_prefs.imperial
    if imperial do
      Distances.mile_in_meters
    else
      1000
    end
  end

  def calc_split({trackpoints, idx}) do
    last = List.last(trackpoints)
    altitude_deltas = calc_up_and_downs(trackpoints)
    %{
      split: idx + 1,
      distance: last.distance,
      time: last.time,
      heartrate: round(avg_by(trackpoints, :heartrate)),
      cadence: round(avg_by(trackpoints, :cadence) * 2),
      up: altitude_deltas.up,
      down: altitude_deltas.down
    }
  end

  defp avg_by(trackpoints, field) do
    sum = trackpoints
    |> Enum.map(&(Map.get(&1, field)))
    |> Enum.sum()
    sum / length(trackpoints)
  end

  defp calc_up_and_downs(trackpoints) do
    first = List.first(trackpoints)
    acc = %{up: 0, down: 0, altitude: first.altitude}
    trackpoints
    |> Enum.reduce(acc, fn(x, %{up: up, down: down, altitude: altitude}) ->
      delta = x.altitude - altitude
      if delta >= 0 do
        %{up: up + delta, down: down, altitude: x.altitude}
      else
        %{up: up, down: down - delta, altitude: x.altitude}
      end
    end)
  end
end
