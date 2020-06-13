defmodule SqueezeWeb.SearchView do
  use SqueezeWeb, :view

  alias Squeeze.Regions

  def title(_page, _), do: "Search For Your Next Race"

  def states do
    Regions.states
  end
end
