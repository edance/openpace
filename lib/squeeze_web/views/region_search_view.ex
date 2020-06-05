defmodule SqueezeWeb.RegionSearchView do
  use SqueezeWeb, :view

  def title(_page, _), do: "Region Search"

  def h1(%{region: region}) do
    "Best races in #{String.capitalize(region)}"
  end
end
