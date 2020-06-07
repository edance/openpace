defmodule SqueezeWeb.RegionSearchView do
  use SqueezeWeb, :view

  def title(_page, assigns) do
    "Best races in #{region_name(assigns)}"
  end

  def region_name(%{region: region}) do
    String.capitalize(region)
  end

  def h1(assigns) do
    "Best races in #{region_name(assigns)}"
  end
end
