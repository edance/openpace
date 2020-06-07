defmodule SqueezeWeb.DistanceSearchController do
  use SqueezeWeb, :controller

  def index(conn, %{"region" => region, "distance" => distance} = params) do
    case find_races(params) do
      {:ok, results} ->
        render(conn, "index.html", region: region, distance: distance, results: results)
      _ ->
        render(conn, "index.html", region: region, distance: distance)
    end
  end

  defp find_races(params) do
    Algolia.search("Race", "", [facetFilters: facet_filters(params), facets: facets()])
  end

  defp facet_filters(%{"region" => region, "distance" => _distance}) do
    ["full_state:#{region}"]
  end

  defp facets do
    ~w(full_state weekday month course_profile course_terrain course_type boston_qualifier)
  end
end
