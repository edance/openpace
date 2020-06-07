defmodule SqueezeWeb.DistanceSearchView do
  use SqueezeWeb, :view

  def title(_page, assigns) do
    "Best races in #{region_name(assigns)}"
  end

  def region_name(%{region: region}) do
    String.capitalize(region)
  end

  def distance_name(%{distance: distance}) do
    distance
    |> String.split("-")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def h1(assigns) do
    "Best races in #{region_name(assigns)}"
  end
end
