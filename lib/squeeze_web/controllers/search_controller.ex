defmodule SqueezeWeb.SearchController do
  use SqueezeWeb, :controller

  alias Squeeze.RaceSearch

  def index(conn, _) do
    case RaceSearch.search() do
      {:ok, results} ->
        render(conn, "index.html", results: results)
      _ ->
        render(conn, "index.html", results: [])
    end
  end
end
