defmodule SqueezeWeb.Activities.SplitsComponent do
  use SqueezeWeb, :live_component
  @moduledoc false

  alias Squeeze.Distances

  def splits(%{trackpoints: trackpoints, current_user: user}) do
    imperial = user.user_prefs.imperial

    {splits, _} = trackpoints
    |> Enum.chunk_by(&(trunc(&1.distance / split_distance(imperial))))
    |> Enum.with_index()
    |> Enum.map(&(calc_split(&1, imperial)))
    |> Enum.map_reduce(List.first(trackpoints), fn(x, acc) ->
      time = x.time - acc.time
      distance = Distances.to_float(x.distance - acc.distance, imperial: imperial)
      pace = time / distance
      {Map.merge(x, %{pace: pace, split_time: time}), x}
    end)

    splits
  end

  def split_distance(imperial) do
    if imperial do
      Distances.mile_in_meters
    else
      1000
    end
  end

  def calc_split({trackpoints, idx}, imperial) do
    last = List.last(trackpoints)
    altitude_deltas = calc_up_and_downs(trackpoints)
    %{
      split: idx + 1,
      distance: last.distance,
      time: last.time,
      up: Distances.to_feet(altitude_deltas.up, imperial: imperial),
      down: Distances.to_feet(altitude_deltas.down, imperial: imperial)
    }
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
