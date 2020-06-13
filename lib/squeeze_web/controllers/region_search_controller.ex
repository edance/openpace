defmodule SqueezeWeb.RegionSearchController do
  use SqueezeWeb, :controller

  alias Squeeze.RaceSearch

  def index(conn, %{"region" => region}) do
    case RaceSearch.search_region(%{region: region}) do
      {:ok, results} ->
        render(conn, "index.html", region: region, results: results)
      _ ->
        render(conn, "index.html", region: region, results: [])
    end
  end
end
