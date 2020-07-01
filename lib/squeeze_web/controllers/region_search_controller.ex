defmodule SqueezeWeb.RegionSearchController do
  use SqueezeWeb, :controller

  alias Squeeze.RaceSearch
  alias Squeeze.Regions

  def index(conn, %{"region" => slug}) do
    region = Regions.from_slug(slug)

    case RaceSearch.search_region(%{region: region.long_name}) do
      {:ok, results} ->
        render(conn, "index.html", region: region, results: results)
      _ ->
        render(conn, "index.html", region: region, results: [])
    end
  end
end
