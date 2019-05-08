defmodule SqueezeWeb.MapView do
  use SqueezeWeb, :view

  def coordinates(%{trackpoints: trackpoints}) do
    trackpoints
    |> Enum.map(&(&1.coordinates))
    |> Enum.map(&([&1["lon"], &1["lat"]]))
    |> Poison.encode!()
  end
end
