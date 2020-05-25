defmodule SqueezeWeb.RegionSearchController do
  use SqueezeWeb, :controller

  def index(conn, %{"distance_type" => distance, "region" => region}) do
    render(conn, "index.html", distance: distance, region: region)
  end
end
