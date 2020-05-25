defmodule SqueezeWeb.RegionSearchView do
  use SqueezeWeb, :view

  def title(_page, _), do: "Region Search"

  def h1(%{distance: distance, region: region}) do
    "Best #{String.capitalize(distance)} in #{String.capitalize(region)}"
  end
end
