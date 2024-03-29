defmodule SqueezeWeb.DistanceSearchView do
  use SqueezeWeb, :view
  @moduledoc false

  def title(_page, assigns) do
    "Best races in #{region_name(assigns)}"
  end

  def region_name(%{region: region}) do
    String.capitalize(region)
  end

  def distance_name(%{distance: distance}) do
    distance
    |> String.split("-")
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  def h1(assigns) do
    "#{distance_name(assigns)} races in #{region_name(assigns)}"
  end
end
