defmodule SqueezeWeb.MapView do
  use SqueezeWeb, :view

  alias Squeeze.Distances

  def coordinates(%{trackpoints: trackpoints}) do
    trackpoints
    |> Enum.map(&map_coordinate/1)
    |> Poison.encode!()
  end

  def markers(%{current_user: user, trackpoints: trackpoints}) do
    imperial = user.user_prefs.imperial
    trackpoints
    |> Enum.group_by(&Distances.to_int(&1.distance, imperial: imperial))
    |> Enum.map(fn({_, v}) -> List.first(v) end)
    |> Enum.map(&map_coordinate/1)
    |> Poison.encode!()
  end

  def map_coordinate(%{coordinates: nil}), do: nil
  def map_coordinate(%{coordinates: coordinates}) do
    [coordinates["lon"], coordinates["lat"]]
  end
end
