defmodule SqueezeWeb.RegionSearchController do
  use SqueezeWeb, :controller

  def index(conn, %{"region" => region}) do
    case find_races(region) do
      {:ok, results} ->
        render(conn, "index.html", region: region, results: results)
      _ ->
        render(conn, "index.html", region: region)
    end
  end

  defp find_races(region) do
    facets = ["course_terrain", "course_profile", "course_type"]
    Algolia.search("Race", "", [facetFilters: ["full_state:#{region}"], facets: facets])
  end
end
