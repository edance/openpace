defmodule Squeeze.RaceSearch do
  @moduledoc false

  @index_name "Race"
  @facets ~w(full_state weekday month course_profile course_terrain course_type boston_qualifier)

  def search do
    Algolia.search(@index_name, "", [facets: @facets])
  end

  def search_region(%{region: region}) do
    Algolia.search(@index_name, "", [facetFilters: ["full_state:#{region}"], facets: @facets])
  end

  def search_distance_region(%{distance: _distance, region: region}) do
    Algolia.search(@index_name, "", [facetFilters: ["full_state:#{region}"], facets: @facets])
  end
end
