defmodule SqueezeWeb.SearchController do
  use SqueezeWeb, :controller

  def index(conn, _) do
    render(conn, "index.html")
  end
end
