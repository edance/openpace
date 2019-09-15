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
    %{
      split: idx + 1,
      time: last.time,
      heartrate: round(avg_by(trackpoints, :heartrate)),
      cadence: round(avg_by(trackpoints, :cadence) * 2)
    }
  end

  defp avg_by(trackpoints, field) do
    sum = trackpoints
    |> Enum.map(&(Map.get(&1, field)))
    |> Enum.sum()
    sum / length(trackpoints)
  end
end
