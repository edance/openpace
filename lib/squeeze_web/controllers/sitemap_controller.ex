defmodule SqueezeWeb.SitemapController do
  use SqueezeWeb, :controller

  alias Squeeze.Races

  def index(conn, _params) do
    races = Races.list_races()
    render(conn, "index.xml", races: races)
  end
end
