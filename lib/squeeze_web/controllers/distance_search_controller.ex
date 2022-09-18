defmodule SqueezeWeb.DistanceSearchController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.RaceSearch

  def index(conn, %{"region" => region, "distance" => distance}) do
    case RaceSearch.search_distance_region(%{distance: distance, region: region}) do
      {:ok, results} ->
        render(conn, "index.html", region: region, distance: distance, results: results)
      _ ->
        render(conn, "index.html", region: region, distance: distance)
    end
  end
end
