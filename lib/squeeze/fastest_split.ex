defmodule Squeeze.FastestSplit do
  @moduledoc """
  Finds the fastest split in an trackpoints for a given distance.
  """

  @doc """
  Returns a tuple of two trackpoints for the fastest split at the given distance.

  Distances is in meters
  """
  def find_for_distance(trackpoints, distance) do
    trackpoints
    |> Enum.map(&trackpoint_pair(&1, trackpoints, distance))
    |> Enum.reject(&is_nil/1)
    |> Enum.min_by(fn {tp, tp2} -> tp2.time - tp.time end)
  rescue
    Enum.EmptyError -> nil
  end

  defp trackpoint_pair(tp, trackpoints, distance) do
    tp2 =
      trackpoints
      |> Enum.find(&(&1.distance - tp.distance >= distance))

    if is_nil(tp2) do
      nil
    else
      {tp, tp2}
    end
  end
end
